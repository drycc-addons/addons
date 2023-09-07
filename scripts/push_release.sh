#!/usr/bin/env bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Some parameters [GIT_TAG, GIT_REPO] were not provided"
    exit
fi

GIT_TAG=$1
GIT_REPO=$2

CREATE_RELEASE_DATA='{
  "tag_name": "'"${GIT_TAG}"'",
  "target_commitish": "main",
  "name": "'"${GIT_TAG}"'",
  "body": "release-'"${GIT_TAG}"'",
  "draft": false,
  "prerelease": false
  }'

echo "Creating a new release: $GIT_TAG branch: main"

RESPONSE=$(curl -s --data "${CREATE_RELEASE_DATA}" -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/$GIT_REPO/releases")
ASSET_UPLOAD_URL=$(echo "$RESPONSE" | jq -r .upload_url | cut -d '{' -f1)
if [ -z "$ASSET_UPLOAD_URL" ]; then
    echo ${RESPONSE}
    exit 1
fi

# modify index.yaml, add created\digest field
if [ ! -f toCopy/index.yaml ]; then
    echo "index.yaml does not exist"
    exit 1
fi
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
for FILE in `ls toCopy/*.tgz`; do
    sha=$(sha256sum $FILE | awk '{ print $1 }')  # FILE Example: toCopy/minio-2023.tgz
    FILE=${FILE%%.tgz*}  # remove ".tgz", Example: toCopy/minio-2023
    addonVersion=${FILE##*toCopy/}  # remove "path, Example: minio-2023
    addon=${addonVersion%-*}  # remove after "-" , Example: minio
    version=${addonVersion##*-}  # remove before "-", Example: 2023
    a=$addon v=$version t=$timestamp yq -i '(.entries.[env(a)][] | select(.version == env(v)) | .created) = env(t)' toCopy/index.yaml
    a=$addon v=$version s=$sha yq -i '(.entries.[env(a)][] | select(.version == env(v)) | .digest) = env(s)' toCopy/index.yaml
done

for FILE in toCopy/*; do
    echo "Uploading asset: $FILE to url: $ASSET_UPLOAD_URL?name=${FILE}"
    curl -s --data-binary @${FILE} -H "Content-Type: application/octet-stream" -H "Authorization: token ${GITHUB_TOKEN}" -X POST "$ASSET_UPLOAD_URL?name=$(basename ${FILE})"
done