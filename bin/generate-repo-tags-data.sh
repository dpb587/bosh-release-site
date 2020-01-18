#!/bin/bash

set -eu

sitedir="$( realpath "$PWD" )"
repo="$1"

mkdir -p "$sitedir/data/repo"

cd "$repo"

(
  echo 'dates:'
  for tag in $( git tag -l ); do
    echo "$tag: $( git log -n1 --pretty='format:%ai' "$tag" )"
  done
) > "$sitedir/data/repo/tags.yml"
