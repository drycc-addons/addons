#!/usr/bin/env bash
source_dir=$1
destination_dir=$2

cd $source_dir
for addon in *; do
  if [[ -d $addon ]]; then
    addon=$(echo $addon | awk -F '/' '{print $NF}')
    tar -czvf ../$destination_dir/$addon.tgz $addon
  fi
done