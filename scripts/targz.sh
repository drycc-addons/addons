#!/usr/bin/env bash
source_dir=$1
destination_dir=$2

cd $source_dir
for addon in *; do
  addon=$(echo $addon | awk -F '/' '{print $NF}')
  for v in `ls $addon`; do
    if [[ -d $addon/$v ]]; then
      tar -czvf ../$destination_dir/$addon-$v.tgz -C $addon/$v/ .
    fi
  done
done