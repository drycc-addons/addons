## CREATE PG INSTANCE

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
    awsAccessKeyID: DO9l771LqiwZkhhz
    awsSecretAccessKey: R3Dv0NEmJBo8JFdn1q8jz49ArWwpDjFn
    walGS3Prefix: mx-test
```

## Create app user and database

- Login PG with admin user & password

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

## Network Access

Default access allow policy: only namespace scope.

- allow `mx-test1` namespace access 
```
networkPolicy.allowNamespaces:
 - mx-test1 
```

 - Assign external network IP address
```
 service.type: LoadBlance
```

 ## Manger backup your data `Very important`
 
`Strongly recommend enabling this feature.`
`Strongly recommend enabling this feature.`
`Strongly recommend enabling this feature.`

PG data backup use S3 as backenp store. Choose an independent storage space `outside of the current environment` as your backup space.
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

You can modify multiple content at once, there is no need to modify part of it each time.

## Plans

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

