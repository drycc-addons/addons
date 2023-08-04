# Addons

[![Build Status](https://woodpecker.drycc.cc/api/badges/60/status.svg)](https://woodpecker.drycc.cc/drycc-addons/addons)

## Overview

This repository contains addons which the Helm Broker uses. For more information on what the Helm Broker is, how it uses addons, and how to create your own addons, read the Helm Broker [helmbroker](https://github.com/drycc/helmbroker).

The charts of this project refer to the [charts](https://github.com/bitnami/charts) project of bitnami.

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
