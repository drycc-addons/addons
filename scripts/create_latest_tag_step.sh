#!/usr/bin/env bash
set -e

GIT_REPO=$1

export HOME=$(mktemp)
export GIT_TAG=latest
git config user.name "drycc"
git config user.email "drycc@drycc.cc"
git tag $GIT_TAG -f -a -m "Generated tag from ProwCI"
echo git push https://${GITHUB_TOKEN}@github.com/${GIT_REPO} ${GIT_TAG} -f
git push https://${GITHUB_TOKEN}@github.com/${GIT_REPO} ${GIT_TAG} -f
