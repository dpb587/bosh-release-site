#!/usr/bin/env bash

set -eu

pwd=$PWD
gitroot=$( realpath "$1" )
artifactroot=$( realpath "$2" )
siteroot=$( mkdir -p "$3" ; realpath "$3" )

dataroot="$siteroot/data"
mkdir -p "$dataroot"

meta4-repo filter --format=json "file://$artifactroot" \
  > "$dataroot/sourceRelease.json"

(
  cd "$gitroot"

  echo 'dates:'
  git log --tags --simplify-by-decoration --pretty="format:%D: %ai" | sed 's#^HEAD -> master, ##' | sed 's#, origin/master:#:#' | grep -E '^tag: [^ ]+:' | sed 's#^tag: #  #'
) > "$dataroot/repositoryTags.yml"
