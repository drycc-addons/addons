# ReplicatedMergeTree 单节点磁盘故障模拟与恢复

本文基于 `addons/addons/clickhouse/26`（服务名 `clickhouse-26`，Chart 目录 `chart/clickhouse-26`），拓扑为 **1 shard × 3 replicas**（`shards=1`，`replicaCount=3`，`keeper.enabled=true`）。

目标：模拟单个副本磁盘不可用，并利用另外两个副本将故障节点恢复到可服务状态。

---

## 1. 环境与命名约定

### 1.1 拓扑

| 项目 | 值 |
|------|-----|
| Shard | 1（`shard0`） |
| 副本数 | 3 |
| StatefulSet | `<fullname>-shard0` |
| Pod | `<fullname>-shard0-0` / `-1` / `-2` |
| PVC | `data-<fullname>-shard0-<N>` |
| 数据挂载 | `/drycc/clickhouse`（ClickHouse 数据与内嵌 Keeper 同盘） |
| 集群名（`remote_servers`） | `cluster` |
| 副本宏 `{replica}` | Pod 名（`CLICKHOUSE_REPLICA_ID=metadata.name`） |
| 分片宏 `{shard}` | `shard0` |

### 1.2 变量占位符

下文命令中请替换：

```bash
export NS=<namespace>                          # 实例所在命名空间
export FULLNAME=<fullname>                   # 如 hb-clickhouse-cluster-standard-8c32g500
export STS="${FULLNAME}-shard0"
export FAIL_ORDINAL=1                          # 模拟故障的副本序号：0 / 1 / 2
export FAIL_POD="${STS}-${FAIL_ORDINAL}"
export FAIL_PVC="data-${FAIL_POD}"
export CH_USER=administrator
# 密码：
# kubectl -n "$NS" get secret "$FULLNAME" -o jsonpath='{.data.admin-password}' | base64 -d
export CH_PASS='<admin-password>'
```

### 1.3 登录客户端（下文复用）

```bash
# 取密码
export CH_PASS="$(kubectl -n "$NS" get secret "$FULLNAME" -o jsonpath='{.data.admin-password}' | base64 -d)"

# 进入任一副本执行 SQL（推荐固定用 -0，演练全程一致）
ch() {
  kubectl -n "$NS" exec -i "${STS}-0" -- \
    clickhouse-client -u "$CH_USER" --password "$CH_PASS" --multiquery "$@"
}

# 交互式：
# kubectl -n "$NS" exec -it "${STS}-0" -- clickhouse-client -u "$CH_USER" --password "$CH_PASS"
```

---

## 2. 演练准备：建表、插入测试数据、查看集群健康

故障演练前必须先有可验证的数据基线。本节完成后，三个副本应都能查到相同行数，且复制状态健康。

### 2.1 建库建表（必须用 ReplicatedMergeTree）

```bash
ch -q "
CREATE DATABASE IF NOT EXISTS demo ON CLUSTER cluster;

CREATE TABLE IF NOT EXISTS demo.events ON CLUSTER cluster
(
    id UInt64,
    event_time DateTime,
    payload String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{layer}/{shard}/demo/events', '{replica}')
PARTITION BY toYYYYMM(event_time)
ORDER BY (id, event_time);
"
```

也可用默认 ZK 路径写法（等价，宏仍生效）：

```sql
CREATE TABLE IF NOT EXISTS demo.events ON CLUSTER cluster
(
    id UInt64,
    event_time DateTime,
    payload String
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(event_time)
ORDER BY (id, event_time);
```

说明：

- `{layer}` / `{shard}` / `{replica}` 来自 Chart `<macros>`（`layer`=fullname，`shard`=`shard0`，`replica`=Pod 名）。
- `ON CLUSTER cluster` 与 `remote_servers` 里集群名一致，DDL 会下发到 3 个副本。
- 普通 `MergeTree` **不能**靠副本回补，不要用于本演练。

确认三个节点都有表：

```bash
ch -q "
SELECT hostName(), database, name, engine
FROM clusterAllReplicas('cluster', system.tables)
WHERE database = 'demo' AND name = 'events'
ORDER BY hostName()
"
```

期望：3 行，`engine` 均以 `Replicated` 开头。

### 2.2 插入测试数据

```bash
# 批量插入 10000 行（可按需改 numbers()）
ch -q "
INSERT INTO demo.events
SELECT
    number AS id,
    now() - number AS event_time,
    concat('payload-', toString(number)) AS payload
FROM numbers(10000);

-- 再插入若干带标记的行，便于恢复后按 id 抽查
INSERT INTO demo.events VALUES
    (1000001, now(), 'seed-marker-a'),
    (1000002, now(), 'seed-marker-b'),
    (1000003, now(), 'seed-marker-c');
"
```

等待复制追上（通常数秒）：

```bash
ch -q "SYSTEM SYNC REPLICA demo.events"
# 若当前连的是 -0，再在其他副本上 sync 也可（可选）
```

### 2.3 核对数据已在三个副本落盘

```bash
ch -q "
-- 各副本行数应一致（10000 + 3 = 10003）
SELECT hostName(), count() AS rows
FROM clusterAllReplicas('cluster', demo.events)
GROUP BY hostName()
ORDER BY hostName();

-- 抽查标记行
SELECT hostName(), id, payload
FROM clusterAllReplicas('cluster', demo.events)
WHERE id IN (1000001, 1000002, 1000003)
ORDER BY id, hostName();

-- part / rows 基线（恢复后对比用，请记录）
SELECT hostName(), count() AS parts, sum(rows) AS rows
FROM clusterAllReplicas('cluster', system.parts)
WHERE active AND database = 'demo' AND table = 'events'
GROUP BY hostName()
ORDER BY hostName();
"
```

期望：三个 `hostName()` 的 `rows` 相同；标记行在三个副本都能查到。

### 2.4 查看集群健康状态

演练前、故障中、恢复后都应用同一套检查。下列全部通过再进入故障模拟。

#### （1）Kubernetes 层

```bash
kubectl -n "$NS" get pod -l app.kubernetes.io/component=clickhouse -o wide
kubectl -n "$NS" get pvc | grep "${FULLNAME}-shard0"
kubectl -n "$NS" get sts "$STS"
```

期望：3 个 Pod `Running`/`Ready`，3 个 PVC `Bound`，STS `READY 3/3`。

#### （2）集群拓扑（remote_servers）

```bash
ch -q "
SELECT cluster, shard_num, replica_num, host_name, port, errors_count, is_local
FROM system.clusters
WHERE cluster = 'cluster'
ORDER BY shard_num, replica_num
"
```

期望：1 个 shard、3 个 replica；`errors_count = 0`。

#### （3）复制与只读状态（核心）

```bash
ch -q "
SELECT
    hostName() AS host,
    database,
    table,
    replica_name,
    is_leader,
    total_replicas,
    active_replicas,
    is_readonly,
    absolute_delay,
    queue_size,
    inserts_in_queue,
    merges_in_queue,
    last_exception
FROM clusterAllReplicas('cluster', system.replicas)
WHERE database = 'demo' AND table = 'events'
ORDER BY host
FORMAT Vertical
"
```

健康判定：

| 字段 | 期望 |
|------|------|
| `total_replicas` | 3 |
| `active_replicas` | 3 |
| `is_readonly` | 0 |
| `absolute_delay` | 0（或接近 0） |
| `queue_size` | 0 |
| `last_exception` | 空 |

一句话汇总（适合反复刷）：

```bash
ch -q "
SELECT
    hostName(),
    is_readonly,
    absolute_delay,
    queue_size,
    active_replicas,
    total_replicas
FROM clusterAllReplicas('cluster', system.replicas)
WHERE database = 'demo' AND table = 'events'
ORDER BY 1
"
```

#### （4）Keeper / ZooKeeper 连通性

```bash
ch -q "
-- 能连上协调服务则返回路径列表（非空即基本正常）
SELECT name FROM system.zookeeper WHERE path = '/' LIMIT 20;

-- 复制表在 ZK 上的路径是否存在（路径随建表宏变化，可用模糊查）
SELECT name FROM system.zookeeper
WHERE path = '/clickhouse/tables'
LIMIT 50;
"
```

若 `system.zookeeper` 查询报错（connection refused / timeout），说明 Keeper quorum 异常，**不要**继续做删盘演练。

#### （5）副本间连通（Distributed 探测）

```bash
ch -q "
SELECT hostName() AS from_host, *
FROM clusterAllReplicas('cluster', system.one)
ORDER BY from_host
"
```

期望：返回 3 行（每个副本各一行）。少于 3 行说明集群互访或某副本未就绪。

#### （6）健康检查速查脚本

```bash
echo '=== Pod / PVC ==='
kubectl -n "$NS" get pod,pvc | grep -E "${FULLNAME}-shard0|NAME"

echo '=== replicas health ==='
ch -q "
SELECT hostName(), is_readonly, absolute_delay, queue_size, active_replicas
FROM clusterAllReplicas('cluster', system.replicas)
WHERE database='demo' AND table='events' ORDER BY 1"

echo '=== row counts ==='
ch -q "
SELECT hostName(), count() FROM clusterAllReplicas('cluster', demo.events)
GROUP BY 1 ORDER BY 1"
```

全部正常后，记录当前 `count()` / `parts`，再进入故障模拟。

---

## 3. 故障模拟（略）

任选一种方式，使 **仅一个** 副本的数据盘失效，并保证另两个 Pod 仍 Running：

1. **推荐（贴近真实换盘）**：删除故障 Pod 对应 PVC，使本地数据与该节点 Keeper 状态一并丢失（见第 4 节恢复步骤，模拟与恢复可合并执行）。
2. **节点级**：将承载该 Pod 的 Node `cordon` + 模拟磁盘 I/O 错误，或对该 PVC 对应 PV 做强制异常（依赖存储实现）。
3. **进程级（仅测只读/断连，不测换盘）**：`kubectl delete pod $FAIL_POD` 且暂不重建 PVC——只能验证短时副本不可用，**不能**覆盖空盘重建场景。

硬性约束：

- **一次只故障 / 重建一个 ordinal**（0、1、2 中的一个）。
- 另两个副本与 Keeper 必须保持多数派（3 节点 Raft 至少存活 2 个），否则无法写入、也无法可靠回补。

故障注入后立刻复查健康（此时故障副本会异常，健康副本应仍可写）：

```bash
kubectl -n "$NS" get pod -l app.kubernetes.io/component=clickhouse -o wide

ch -q "
SELECT hostName(), is_readonly, absolute_delay, queue_size, active_replicas
FROM clusterAllReplicas('cluster', system.replicas)
WHERE database = 'demo' AND table = 'events'
ORDER BY 1;

-- 健康节点仍应能写入
INSERT INTO demo.events VALUES (900001, now(), 'during-failure-probe');
SELECT count() FROM demo.events;
"
```

---

## 4. 恢复方法（详细）

### 4.1 恢复原理

Chart 中副本身份与存储关系如下：

1. **副本身份固定为 Pod 名**  
   `CLICKHOUSE_REPLICA_ID` 取自 `metadata.name`。只要 StatefulSet ordinal 不变（仍是 `…-shard0-1`），ZooKeeper/Keeper 中的 replica 路径不变。
2. **数据在 PVC `data` 上**  
   `volumeClaimTemplates` 名为 `data`，挂载 `/drycc/clickhouse`。清空并重建该 PVC = 该副本本地 part 与本节点 Keeper 日志全部清空。
3. **回补靠 ReplicatedMergeTree**  
   同名副本以空数据目录重新加入后，通过 Keeper 元数据发现缺失 part，经 **interserver（9009）** 从其他活跃副本拉取。无需手工 `rsync` part 目录。
4. **内嵌 Keeper**  
   三个 Pod 同为 Keeper 成员。删掉其中一个 PVC 会丢掉该节点的 Keeper 数据，但另两个仍构成 quorum；该节点重启后由 Raft 追上。因此恢复窗口内 **禁止** 再动第二个副本。

推荐策略：**同名副本 + 空盘重建（Replace PVC，Keep Ordinal）**。

```text
故障盘 (…-shard0-1)
    → 确认 …-0 / …-2 健康
    → 删除 Pod + 删除 PVC data-…-shard0-1
    → STS 拉起同名 Pod + 新空 PVC
    → RMT 按 {replica}=Pod 名从同伴拉取 part
    →（可选）SYSTEM DROP REPLICA 清理脏元数据后再拉
    → SYNC / 比对 parts 完成验收
```

### 4.2 恢复前检查清单

在健康 Pod（例如 `${STS}-0`）上执行。

#### 步骤 A：集群与副本存活

```bash
kubectl -n "$NS" get pod -l app.kubernetes.io/component=clickhouse
kubectl -n "$NS" get pvc | grep "${FULLNAME}-shard0"
```

期望：除拟恢复的那一个外，另两个 Pod 为 `Running` / `Ready`。

#### 步骤 B：复制队列与只读状态

```bash
kubectl -n "$NS" exec -it "${STS}-0" -- clickhouse-client -u "$CH_USER" --password "$CH_PASS" -q "
SELECT
    hostName() AS host,
    database,
    table,
    replica_name,
    is_readonly,
    absolute_delay,
    queue_size,
    inserts_in_queue,
    merges_in_queue,
    last_exception
FROM clusterAllReplicas('cluster', system.replicas)
WHERE database = 'demo'
ORDER BY table, host
FORMAT Vertical"
```

期望（健康副本）：

- `is_readonly = 0`
- `absolute_delay` 接近 0 或在可接受范围
- `last_exception` 为空，或不影响拉数

若 **两个以上** 副本 `is_readonly=1` 或 Keeper 不可用，先恢复协调层 / 其他节点，**不要**继续删 PVC。

#### 步骤 C：健康副本数据基线（用于恢复后对比）

```bash
kubectl -n "$NS" exec -it "${STS}-0" -- clickhouse-client -u "$CH_USER" --password "$CH_PASS" -q "
SELECT hostName(), count() AS parts, sum(rows) AS rows
FROM clusterAllReplicas('cluster', system.parts)
WHERE active AND database = 'demo' AND table = 'events'
GROUP BY hostName()
ORDER BY hostName()"
```

记录健康副本的 `parts` / `rows`，作为验收基线。

#### 步骤 D：（可选）写入探针，确认故障期间集群仍可写

```sql
INSERT INTO demo.events VALUES (900001, now(), 'pre-recovery-probe');
```

若插入失败且报 ZooKeeper / readonly，说明 quorum 已丢，停止恢复流程并优先抢修任一健康节点。

---

### 4.3 标准恢复流程：删除坏盘 PVC，同名空盘拉起

#### 步骤 1：隔离故障 Pod

```bash
# 若节点磁盘已坏、Pod 卡在 Terminating / CrashLoop，可强制删除
kubectl -n "$NS" delete pod "$FAIL_POD" --grace-period=0 --force
```

说明：仅删 Pod **不删 PVC** 时，STS 会重建 Pod 并重新挂载**同一块坏盘**，无法完成换盘恢复。

#### 步骤 2：删除故障 PVC（触发换盘）

```bash
kubectl -n "$NS" get pvc "$FAIL_PVC" -o wide
kubectl -n "$NS" delete pvc "$FAIL_PVC"
```

若 PVC 一直处于 `Terminating`（常见于坏盘导致 volumeattachment 残留）：

```bash
kubectl -n "$NS" patch pvc "$FAIL_PVC" --type=merge \
  -p '{"metadata":{"finalizers":null}}'
```

必要时再由集群管理员处理异常 `VolumeAttachment` / 节点上的残留挂载。

**注意：**

- Chart 中 `persistentVolumeClaimRetentionPolicy.whenScaled=Retain`，缩容不会自动删盘；故障换盘必须 **显式 delete pvc**。
- **不要**删除整个 StatefulSet，也 **不要** `helm uninstall`（`whenDeleted=Delete` 会删掉全部 3 块盘）。

#### 步骤 3：等待 STS 重建同名 Pod 与新 PVC

```bash
kubectl -n "$NS" get pvc -w | grep "$FAIL_POD"
kubectl -n "$NS" get pod "$FAIL_POD" -w
```

期望：

1. 出现新的 `data-${FAIL_POD}`，状态 `Bound`
2. `${FAIL_POD}` 重新创建，名称 **与故障前完全一致**
3. 容器 Ready（`/ping` 就绪探针通过）

若新 Pod 因节点盘仍坏而调度失败：

```bash
kubectl cordon <坏节点名>
kubectl -n "$NS" delete pod "$FAIL_POD"
# STS 会在可调度节点上拉起同名 Pod，并绑定新的 RWO PVC
```

#### 步骤 4：确认 macros 与 Keeper 身份

进入恢复中的 Pod：

```bash
kubectl -n "$NS" exec -it "$FAIL_POD" -- bash -lc '
  echo "hostname=$(hostname -s)";
  clickhouse-client -u '"$CH_USER"' --password '"$CH_PASS"' -q "
    SELECT getMacro('\''shard'\''), getMacro('\''replica'\''), getMacro('\''layer'\'')"
'
```

期望：

- `shard` = `shard0`
- `replica` = `$FAIL_POD`（完整 Pod 名）
- `layer` = `$FULLNAME`

Keeper `server_id` 由 `setup.sh` 按 hostname ordinal 解析（0/1/2），与 `raft_configuration` 中 id 一致即可。

#### 步骤 5：观察自动回补

在 **恢复中的 Pod** 上：

```bash
kubectl -n "$NS" exec -it "$FAIL_POD" -- clickhouse-client -u "$CH_USER" --password "$CH_PASS" -q "
SELECT
    database,
    table,
    is_readonly,
    absolute_delay,
    queue_size,
    inserts_in_queue,
    merges_in_queue,
    log_max_index,
    log_pointer,
    last_exception
FROM system.replicas
WHERE database = 'demo'
FORMAT Vertical"
```

解读：

| 现象 | 含义 | 处理 |
|------|------|------|
| `queue_size` 下降、`absolute_delay` 下降 | 正在从同伴拉取 | 等待 |
| `is_readonly=1` 短暂出现 | 启动期连 Keeper / 初始化 | 等待数十秒再查 |
| `queue_size` 长期不降且 `last_exception` 有错 | 拉取失败或元数据异常 | 见 4.4 |
| 表不存在于本节点 | `ON CLUSTER` 未覆盖或库表未复制创建 | 在本节点补 `CREATE` 或检查 DDL |

主动触发同步（按表执行）：

```sql
SYSTEM SYNC REPLICA demo.events;
-- 较新版本可用：
-- SYSTEM SYNC REPLICA demo.events STRICT;
```

在健康节点看全集群 part 是否对齐：

```sql
SELECT hostName(), count() AS parts, sum(rows) AS rows
FROM clusterAllReplicas('cluster', system.parts)
WHERE active AND database = 'demo' AND table = 'events'
GROUP BY hostName()
ORDER BY hostName();
```

#### 步骤 6：业务验收

```sql
-- 1) 各副本行数一致（应回到演练前基线，如 10003 + 故障中写入）
SELECT hostName(), count()
FROM clusterAllReplicas('cluster', demo.events)
GROUP BY hostName();

-- 2) 标记行仍在（证明从同伴拉回了历史数据，而非空库）
SELECT hostName(), id, payload
FROM clusterAllReplicas('cluster', demo.events)
WHERE id IN (1000001, 1000002, 1000003)
ORDER BY id, hostName();

-- 3) 恢复节点可写可查
INSERT INTO demo.events VALUES (900002, now(), 'post-recovery-probe');
SELECT * FROM demo.events WHERE id IN (900001, 900002) ORDER BY id;

-- 4) 复制延迟归零
SELECT hostName(), absolute_delay, queue_size, is_readonly, active_replicas
FROM clusterAllReplicas('cluster', system.replicas)
WHERE database = 'demo' AND table = 'events';
```

验收通过标准建议：

- 三个副本 `is_readonly = 0`，`active_replicas = 3`
- `absolute_delay = 0`（或业务可接受阈值内）
- `queue_size = 0`
- 关键表 `count()` 在三个 host 上一致，且不低于故障前基线
- `seed-marker-*` 标记行在三个副本均可查到
- 新写入能在三个副本上查到（`internal_replication=true` 时由复制传播）

#### 步骤 7：恢复后清理

```bash
kubectl uncordon <先前 cordon 的节点>   # 若做过
kubectl -n "$NS" get pod,pvc | grep "$STS"
```

确认只有 3 个 PVC、无残留 `Terminating` 声明卷。

---

### 4.4 自动回补失败时的处理

当空盘 Pod 已 Ready，但 `system.replicas` 长期异常时，按顺序尝试。

#### 方案 A：重启恢复中的 Pod（轻量）

```bash
kubectl -n "$NS" delete pod "$FAIL_POD"
# 等待 Ready 后再次 SYSTEM SYNC REPLICA
```

适用于：临时 DNS / interserver / Keeper 连接抖动。

#### 方案 B：`SYSTEM DROP REPLICA` 清理 Keeper 中该副本元数据后重建

在 **健康节点**（例如 `${STS}-0`）执行，**不要**在空盘节点上对业务表执行 `DROP TABLE`。

按表清理：

```sql
SYSTEM DROP REPLICA '<fullname>-shard0-1' FROM TABLE demo.events;
```

按库清理（该库下所有复制表）：

```sql
SYSTEM DROP REPLICA '<fullname>-shard0-1' FROM DATABASE demo;
```

将 `'<fullname>-shard0-1'` 换成实际 `$FAIL_POD`。

然后重启故障 Pod，让其按 macros 重新注册副本并全量拉取：

```bash
kubectl -n "$NS" delete pod "$FAIL_POD"
```

再重复 4.3 步骤 5～6。

适用场景：

- Keeper 中仍残留旧 part 队列 / 损坏的 replica 节点
- 空盘启动后报 replica 路径冲突、无法 attach
- `last_exception` 明确指向 metadata / checksum / unexpected part 且无法自愈

#### 方案 C：检查网络与端口

Chart 中副本间依赖：

| 用途 | 端口（默认） |
|------|----------------|
| 客户端 TCP | 9000 |
| Interserver 复制 | 9009 |
| Keeper 客户端 | 2181 |
| Keeper Raft | 9444 |

```bash
# 从恢复 Pod 解析并探测同伴
kubectl -n "$NS" exec -it "$FAIL_POD" -- bash -lc '
  for i in 0 1 2; do
    H="'"${STS}"'-${i}.'"${FULLNAME}"'-headless"
    echo "== $H";
    getent hosts "$H" || true
  done
'
```

确认 NetworkPolicy / 防火墙未阻断同组件 Pod 互访（Chart 默认 `networkPolicy.allowExternal=true`，但仍需确认集群侧策略）。

#### 方案 D：单表手动对齐（最后手段）

仅当某一张表无法自动修复、且可接受短时只读操作时：

1. 在健康节点确认该表数据完整。
2. `SYSTEM DROP REPLICA ... FROM TABLE ...`（见方案 B）。
3. 在恢复节点对应该表执行与原先一致的 `CREATE TABLE ... ReplicatedMergeTree(...)`（若本地无表结构）。
4. `SYSTEM SYNC REPLICA ...` 并核对 `system.parts`。

**禁止**：把健康节点 `/drycc/clickhouse` 目录 `rsync` 到空盘节点。本地 part 与 Keeper 元数据极易不一致，导致更难修复。

---

### 4.5 多表 / 多库时的操作顺序

1. 先完成 **PVC 级** 空盘重建（4.3 步骤 1～4），只需做一次。
2. 对每个复制库表检查 `system.replicas`；优先 `SYSTEM SYNC REPLICA`。
3. 仅对仍失败的表执行 `SYSTEM DROP REPLICA ... FROM TABLE`。
4. 用脚本批量验收，例如：

```sql
SELECT
    hostName(),
    database,
    table,
    is_readonly,
    absolute_delay,
    queue_size
FROM clusterAllReplicas('cluster', system.replicas)
WHERE engine LIKE 'Replicated%'
ORDER BY database, table, hostName();
```

全部 `is_readonly=0` 且 `queue_size=0` 后再恢复业务流量权重（若前面摘过流量）。

---

### 4.6 恢复期间的读写建议

| 操作 | 建议 |
|------|------|
| 查询 | 可通过 Service 访问；若担心读到未追上的空副本，可临时只连健康 Pod 的 headless FQDN |
| 写入 | 在 quorum 正常时可继续写；新数据会进入健康副本，恢复节点随后追日志 |
| 变更 DDL | 恢复完成前尽量避免 `ALTER` / `DROP` / 大规模 `DELETE` mutation |
| 滚动重启 | 禁止再重启另外两个副本 |
| 扩缩容 | 禁止此时改 `replicaCount` / `shards` |

定向连接健康副本示例：

```bash
kubectl -n "$NS" exec -it "${STS}-0" -- clickhouse-client -u "$CH_USER" --password "$CH_PASS"
# 或
clickhouse-client --host "${STS}-0.${FULLNAME}-headless.${NS}.svc.cluster.local" --port 9000 \
  -u "$CH_USER" --password "$CH_PASS"
```

---

## 5. 回滚与失败兜底

若空盘重建后长时间无法追上，且业务可接受「暂时少一个副本」：

1. 保持 `$FAIL_POD` 隔离（删光 PVC 后不要反复折腾），确保 `${STS}-0` 与 `${STS}-2` 稳定服务。
2. 保留故障现场日志：

```bash
kubectl -n "$NS" logs "$FAIL_POD" --tail=500 > /tmp/${FAIL_POD}.log
kubectl -n "$NS" describe pod "$FAIL_POD" > /tmp/${FAIL_POD}.describe
```

3. 评估是否改为：**新建更高 ordinal 不可行**（STS 身份与 `remote_servers` 写死了 `0..replicaCount-1`）。本 Chart 下正确做法仍是修复同一 ordinal，而不是新增 `-3`。
4. 若两副本也出现数据可疑，停止自动修复，改为从备份 / 对象存储冷备恢复（超出本文「利用副本迁移」范围）。

---

## 6. 操作速查

```bash
# === 0) 准备：建表 + 灌数 + 健康检查（演练前） ===
ch -q "
CREATE DATABASE IF NOT EXISTS demo ON CLUSTER cluster;
CREATE TABLE IF NOT EXISTS demo.events ON CLUSTER cluster
(id UInt64, event_time DateTime, payload String)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{layer}/{shard}/demo/events', '{replica}')
PARTITION BY toYYYYMM(event_time) ORDER BY (id, event_time);
INSERT INTO demo.events SELECT number, now()-number, concat('payload-', toString(number)) FROM numbers(10000);
INSERT INTO demo.events VALUES (1000001, now(), 'seed-marker-a'), (1000002, now(), 'seed-marker-b'), (1000003, now(), 'seed-marker-c');
"
ch -q "
SELECT hostName(), count() FROM clusterAllReplicas('cluster', demo.events) GROUP BY 1 ORDER BY 1;
SELECT hostName(), is_readonly, absolute_delay, queue_size, active_replicas
FROM clusterAllReplicas('cluster', system.replicas)
WHERE database='demo' AND table='events' ORDER BY 1;
"

# === 1) 恢复核心三步 ===
kubectl -n "$NS" delete pod "$FAIL_POD" --grace-period=0 --force
kubectl -n "$NS" delete pvc "$FAIL_PVC"
# 等待同名 Pod + 新 PVC Ready

# === 2) 同步与验收 ===
kubectl -n "$NS" exec -it "$FAIL_POD" -- clickhouse-client -u "$CH_USER" --password "$CH_PASS" -q \
  "SYSTEM SYNC REPLICA demo.events"

ch -q "
SELECT hostName(), count() FROM clusterAllReplicas('cluster', demo.events) GROUP BY 1 ORDER BY 1;
SELECT hostName(), id, payload FROM clusterAllReplicas('cluster', demo.events)
WHERE id IN (1000001,1000002,1000003) ORDER BY id, hostName();
"

# === 3) 元数据脏了再执行 ===
# SYSTEM DROP REPLICA '<fullname>-shard0-1' FROM TABLE demo.events;
# kubectl -n "$NS" delete pod "$FAIL_POD"
```

---

## 7. 与 Chart 实现的对应关系

| Chart 实现 | 对恢复的含义 |
|------------|----------------|
| `CLICKHOUSE_REPLICA_ID=metadata.name` | 必须保留同一 Pod 名（同一 ordinal） |
| `volumeClaimTemplates.name=data` | 换盘 = 删 `data-<pod>` |
| 数据与 Keeper 同挂 `/drycc/clickhouse` | 删 PVC 会同时清空该节点 Keeper；依赖另 2 节点 quorum |
| `remote_servers.cluster` 写死 0..N-1 | 不能靠「加第 4 个 Pod」代替修复 |
| `internal_replication=true` | 写入复制由 ClickHouse 负责，恢复节点追日志即可 |
| `pdb.maxUnavailable` 默认 1 | 自愿中断时仍保留 2/3，有利于恢复窗口内的 quorum |
| `whenScaled=Retain` | 必须手动删 PVC 才会换盘 |
| `whenDeleted=Delete` | 禁止用删 STS / uninstall 做单盘恢复 |

---

## 8. 附录：建议的演练记录表

| 项目 | 记录 |
|------|------|
| 演练时间 | |
| Namespace / Fullname | |
| 故障 ordinal | |
| 灌数行数 / 标记 id | 例如 10003；1000001–1000003 |
| 故障前 parts/rows 基线 | |
| 故障前健康检查是否通过 | |
| PVC 删除耗时 | |
| Pod Ready 耗时 | |
| `SYNC REPLICA` 完成耗时 | |
| 是否执行 `DROP REPLICA` | |
| 恢复后三副本 count 是否一致 | |
| 验收结果 | 通过 / 失败 |
| 备注（异常日志摘要） | |
