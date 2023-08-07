#!/usr/bin/env bash
addons=$1

success=$(find $addons -type f -name "meta.yaml" | xargs yq || echo false)
if [[ success == "false" ]]; then
  echo -e "\033[31mCheck meta.yaml format error\033[0m"
  exit 100
else
  echo -e "\033[32mCheck meta.yaml format ok\033[0m"
fi

success=$(find $addons -type f -name "values.yaml" | xargs yq || echo false)
if [[ success == "false" ]]; then
  echo -e "\033[31mCheck values.yaml format error\033[0m"
  exit 100
else
  echo -e "\033[32mCheck values.yaml format ok\033[0m"
fi

for addon in $addons/chart/*/; do
  cd $addon
  success=$(helm dependency update || echo false)
  if [[ success == "false" ]]; then
    echo -e "\033[31mUpdate $addon dependency error\033[0m"
    exit 100
  fi

  for bind in ../../plans/*/bind.yaml; do
    echo -e "Copy $bind"
    cp $bind templates
    success=$(helm template . || echo false)
    rm templates/bind.yaml
    if [[ success == "false" ]]; then
      echo -e "\033[31mCheck $addon error\033[0m"
      exit 100
    else
      echo -e "\033[32mCheck $addon ok\033[0m"
    fi
  done
  rm -rf Chart.lock charts
  cd -
done