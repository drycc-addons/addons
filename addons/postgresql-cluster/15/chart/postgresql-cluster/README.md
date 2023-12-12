
#   Postgresql cluster addons 
## Plans

View and choose the service resource specifications you need.
```
 # drycc resources:plans postgresql-cluster 
```
### Resource specification list
| Resource Specification | Cores | MEMORY | Storage SIZE |
| :---: | :---: | :---: | :---: | 
| standard-10 | 1C | 2G | 10G |  
| standard-20 | 2C | 4G | 20G | 
| standard-50 | 2C | 8G | 50G | 
| standard-100 | 4C | 16G | 100G |  
| standard-200 | 8C | 32G | 200G |  
| standard-400 | 16C | 64G | 400G | 
| standard-800 | 32C | 128G | 800G | 

In order to obtain a better experience, it is recommended not to exceed 80% usage of resource utilization for a long period of time. If there is a need for larger resource scale, please apply for private customization.

## Create Postgresql Cluster Service instance

- Create Postgresql service
```
#  drycc resources:create postgresql-cluster:standard-10 `my_pg_001`
```
- View service status 
```
# drycc resources:describe `my_pg_001`
``` 
- Bind service
```
# drycc resources:bind `my_pg_001`
```
- View resource status 
```
# drycc resources:describe `my_pg_001`
``` 

## Create Service with values file

`vim values.yaml`  
```
#  create or update pg instance template yaml
networkPolicy.allowNamespaces:
 - mx-test1 
service.type: ClusterIP
metrics.enabled: true
backup:
  # whether BackUP should be enabled
  enabled: true
  # Cron schedule for doing base backups
  scheduleCronJob: "20 0 * * 0"
  Amount of base backups to retain
  retainBackups: 2
  s3:
    awsAccessKeyID: ""
    awsSecretAccessKey: ""
    walGS3Prefix: "s3://xx"
    awsEndpoint: "http://xxxx:9000"
    awsS3ForcePathStyle: "true"
    awsRegion: dx-1
```
```
 drycc resources:create postgresql-cluster:standard-10 `my_pg_001` -f ./values.yaml
```

## Update Service 
###  Create app user and database

- Login database web with admin user & password

- CREATE APP USER
```
CREATE USER `my_user` WITH CONNECTION LIMIT `conn_limit` LOGIN ENCRYPTED PASSWORD 'password';
```
- CREATE APP DATABASE
```
CREATE DATABASE `my_db` OWNER `my_user`;
```
- CREATE EXTENSIONS
```
CREATE EXTENSION pg_buffercache;
```

### Network Access 

Default access allow policy: only namespace scope.

- allow `mx-test1` namespace access 

`vim values.yaml `
```
networkPolicy.allowNamespaces:
 - mx-test1 
```
```
drycc resources:update postgresql-cluster:standard-10  `my_pg_001` -f ./values.yaml
```

 - Assign external network IP address 

`vim values.yaml`
``` 
 service.type: LoadBlancer
```
```
drycc resources:update postgresql-cluster:standard-10 `my_pg_001` -f ./values.yaml
```
- View resource status 
```
# drycc resources:describe  `my_pg_001`
``` 

 ### Manger backup your data `Very important`
 
`Strongly recommend enabling this feature.`
`Strongly recommend enabling this feature.`
`Strongly recommend enabling this feature.`

PG data backup use S3 as backenp store. Choose an independent storage space `outside of the current environment` as your backup space.

`vim values.yaml`
```
backup:
  # whether BackUP should be enabled
  enabled: true
  # Cron schedule for doing base backups
  scheduleCronJob: "20 0 * * 0"
  Amount of base backups to retain
  retainBackups: 2
  s3:
    awsAccessKeyID: DO9l771LqiwZkhhz
    awsSecretAccessKey: R3Dv0NEmJBo8JFdn1q8jz49ArWwpDjFn
    walGS3Prefix: mx-test
```
```
drycc resources:update postgresql-cluster:standard-10 `my_pg_001` -f ./values.yaml
```

You can modify multiple content at once, there is no need to modify part of it each time. 


## Destroy Service

- Unbind service first
```
# drycc resources:unbind `my_pg_001`
```
- Destroy service
```
# drycc resources:destroy `my_pg_001`
```