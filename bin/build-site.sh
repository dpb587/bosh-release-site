#!/bin/bash

set -eu

pwd=$PWD
buildroot=$( mkdir -p "$1" ; realpath "$1" )
baseURL="$2"

dataroot="$buildroot/data"
mkdir -p "$dataroot"

contentroot="$buildroot/content"
configroot="$buildroot/config"
dataroot="$buildroot/data"

echo "dataDir: $dataroot" >> $pwd/config.yml

publicroot="$buildroot/public"
mkdir -p "$publicroot"

cd $contentroot

recentdir=""

for config in $( cd $configroot ; ls | sort -rV ); do
  dir=$( echo "$config" | sed 's/\.yml//' )
  if [[ -z "$recentdir" ]]; then
    recentdir=$dir
  fi

  hugo \
    --baseURL "$baseURL/$dir" \
    --destination "$publicroot/$dir" \
    --config "$pwd/config.yml,$configroot/$config" \
    --contentDir "$contentroot/$dir" \
    --themesDir=$pwd/themes
done

cat > $publicroot/index.html <<EOF
<html><head><meta http-equiv="refresh" content="0; url=$baseURL/$recentdir/" /></head></html>
EOF
