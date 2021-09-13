# Addons

[![Build Status](https://drone.drycc.cc/api/badges/drycc/addons/status.svg)](https://drone.drycc.cc/drycc/addons)

## Overview

This repository contains addons which the Helm Broker uses. For more information on what the Helm Broker is, how it uses addons, and how to create your own addons, read the Helm Broker [helmbroker](https://github.com/drycc/helmbroker).

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
memcached  |  128          | Memcached 128 plan which which limit resources memory size 128Mi.
memcached  |  250          | Memcached 250 plan which which limit resources memory size 250Mi.
memcached  |  500          | Memcached 1000 plan which which limit resources memory size 500Mi.
memcached  |  1000         | Memcached 1000 plan which which limit resources memory size 1Gi.
memcached  |  2500         | Memcached 2500 plan which which limit resources memory size 2.5Gi.
memcached  |  5000         | Memcached 5000 plan which which limit resources memory size 5Gi.
memcached  |  10000        | Memcached 10000 plan which which limit resources memory size 10Gi.
memcached  |  20000        | Memcached 20000 plan which which limit resources memory size 20Gi.
memcached  |  30000        | Memcached 30000 plan which which limit resources memory size 30Gi.
memcached  |  40000        | Memcached 40000 plan which which limit resources memory size 40Gi.
memcached  |  50000        | Memcached 50000 plan which which limit resources memory size 50Gi.
mysql      |  standard-25  | mysql standard-25 plan which limit persistence size 25Gi.
mysql      |  standard-50  | mysql standard-50 plan which limit persistence size 50Gi.
mysql      |  standard-100 | mysql standard-100 plan which limit persistence size 100Gi.
mysql      |  standard-200 | mysql standard-200 plan which limit persistence size 200Gi.
mysql      |  standard-400 | mysql standard-400 plan which limit persistence size 400Gi.
mysql      |  standard-800 | mysql standard-800 plan which limit persistence size 800Gi.
mysql      |  standard-1600| mysql standard-1600 plan which limit persistence size 1600Gi.
postgresql |  standard-16  | postgresql standard-16 plan which limit persistence size 16Gi.
postgresql |  standard-64  | postgresql standard-64 plan which limit persistence size 64Gi.
postgresql |  standard-256 | postgresql standard-256 plan which limit persistence size 256Gi.
postgresql |  standard-512 | postgresql standard-512 plan which limit persistence size 512Gi.
postgresql |  standard-768 | postgresql standard-768 plan which limit persistence size 768Gi.
postgresql |  standard-1000| postgresql standard-1000 plan which limit persistence size 1Ti.
redis      |  128          | Redis 128 plan which limit resources memory size 128Mi.
redis      |  250          | Redis 250 plan which limit resources memory size 250Mi.
redis      |  500          | Redis 500 plan which limit resources memory size 500Mi.
redis      |  1000         | Redis 1000 plan which limit resources memory size 1Gi.
redis      |  2500         | Redis 2500 plan which limit resources memory size 2.5Gi.
redis      |  5000         | Redis 5000 plan which limit resources memory size 5Gi.
redis      |  10000        | Redis 10000 plan which limit resources memory size 10Gi.
redis      |  20000        | Redis 20000 plan which limit resources memory size 20Gi.
redis      |  30000        | Redis 30000 plan which limit resources memory size 30Gi.
redis      |  40000        | Redis 40000 plan which limit resources memory size 40Gi.
redis      |  50000        | Redis 50000 plan which limit resources memory size 50Gi
```