#!/bin/bash

set -eu

pwd=$PWD
buildroot=$( mkdir -p "$1" ; realpath "$1" )
baseURL="$2"

contentroot="$buildroot/content"
mkdir -p "$contentroot"

configroot="$buildroot/config"
mkdir -p "$configroot"

publicroot="$buildroot/public"
mkdir -p "$publicroot"

cd $contentroot

firstconfig=""

for config in $( cd $configroot ; ls | gsort -rV ); do
  if [[ -z "$firstconfig" ]]; then
    firstconfig=$configroot/$config
  fi

  dir=$( echo "$config" | sed 's/\.yml//' )
  hugo \
    --baseURL "$baseURL/$dir" \
    --destination "$publicroot/$dir" \
    --config "$pwd/config.yml,$configroot/$config" \
    --contentDir "$contentroot/$dir" \
    --themesDir=$pwd/themes
done

cat > $publicroot/index.html <<EOF
<html><head><meta http-equiv="refresh" content="0; url=$baseURL/$dir/" /></head></html>
EOF
