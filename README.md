# Addons

[![Build Status](https://drone.drycc.cc/api/badges/drycc-addons/addons/status.svg)](https://drone.drycc.cc/drycc-addons/addons)

## Overview

This repository contains addons which the Helm Broker uses. For more information on what the Helm Broker is, how it uses addons, and how to create your own addons, read the Helm Broker [helmbroker](https://github.com/drycc/helmbroker).

The charts of this project refer to the [charts](https://github.com/bitnami/charts) project of bitnami, 

## Usage

The `addons` folder contains sources of addons and index files that are available in [releases](https://github.com/drycc/addons/releases). Choose a set of addons you want to use, add your own addons, and configure the Helm Broker to fetch them.

### Project structure

The repository has the following structure:

```
  ├── addons                      # Sources of addons
  ├── bin                         # Tools used by CI                                     
  ├── docs                        # Documentation source files
  └── scripts                     # Scripts and tools which check and create addons
```

### Service classes

The repository has the following service classes:

```
CLASS NAME |   PLANS NAME  |           DESCRIPTION
-----------|---------------|------------------------------------
mariadb    |  standard-16  | mysql standard-25 plan which limit persistence size 16Gi.
mariadb    |  standard-64  | mysql standard-50 plan which limit persistence size 64Gi.
mariadb    |  standard-256 | mysql standard-100 plan which limit persistence size 256Gi.
mariadb    |  standard-512 | mysql standard-200 plan which limit persistence size 512Gi.
mariadb    |  standard-768 | mysql standard-400 plan which limit persistence size 768Gi.
mariadb    |  standard-1024| mysql standard-1600 plan which limit persistence size 1Ti.
postgresql |  standard-16  | postgresql standard-16 plan which limit persistence size 16Gi.
postgresql |  standard-64  | postgresql standard-64 plan which limit persistence size 64Gi.
postgresql |  standard-256 | postgresql standard-256 plan which limit persistence size 256Gi.
postgresql |  standard-512 | postgresql standard-512 plan which limit persistence size 512Gi.
postgresql |  standard-768 | postgresql standard-768 plan which limit persistence size 768Gi.
postgresql |  standard-1024| postgresql standard-1000 plan which limit persistence size 1Ti.
kafka      |  standard-16  | kafka standard-16 plan which limit persistence size 16Gi.
kafka      |  standard-64  | kafka standard-64 plan which limit persistence size 64Gi.
kafka      |  standard-256 | kafka standard-256 plan which limit persistence size 256Gi.
kafka      |  standard-512 | kafka standard-512 plan which limit persistence size 512Gi.
kafka      |  standard-768 | kafka standard-768 plan which limit persistence size 768Gi.
kafka      |  standard-1024| kafka standard-1000 plan which limit persistence size 1Ti.
redis      |  128          | Redis 128 plan which limit resources memory size 128Mi.
redis      |  256          | Redis 250 plan which limit resources memory size 256Mi.
redis      |  512          | Redis 500 plan which limit resources memory size 512Mi.
redis      |  1024         | Redis 1000 plan which limit resources memory size 1Gi.
redis      |  2048         | Redis 2500 plan which limit resources memory size 2Gi.
redis      |  4096         | Redis 5000 plan which limit resources memory size 4Gi.
redis      |  8192         | Redis 10000 plan which limit resources memory size 8Gi.
redis      |  16384        | Redis 20000 plan which limit resources memory size 16Gi.
redis      |  32768        | Redis 30000 plan which limit resources memory size 32Gi.
redis      |  65536        | Redis 40000 plan which limit resources memory size 64Gi
```
