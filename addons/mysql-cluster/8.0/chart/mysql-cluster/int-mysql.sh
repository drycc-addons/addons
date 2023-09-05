  int-mysql.sh: |
    #!/bin/bash
    set -ex

    # Generate mysql server-id from pod ordinal index.
    [[ $`hostname` =~ -([0-9]+)$ ]] || exit 1
    ordinal=${BASH_REMATCH[1]}
    echo $ordinal
    mgr_host=`hostname`
    pre_mgr_host=${mgr_host%-*}
    echo [mysqld] > /opt/bitnami/mysql/conf/bitnami/server-id.cnf
    # Add an offset to avoid reserved server-id=0 value.
    echo server-id=$((100 + $ordinal)) >> /opt/bitnami/mysql/conf/bitnami/server-id.cnf
    # Copy appropriate conf.d files from config-map to emptyDir.
    echo loose-group_replication_local_address=$mgr_host:24901 >> /opt/bitnami/mysql/conf/bitnami/server-id.cnf
    echo loose-group_replication_group_seeds= "$pre_mgr_host-0.$pre_mgr_host-1:24901,$pre_mgr_host-2.mysql:24901" >> /opt/bitnami/mysql/conf/bitnami//server-id.cnf

