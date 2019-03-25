#!/bin/bash

set -eu

sitedir="$( realpath "$PWD" )"
repo="$1"

mkdir -p "$sitedir/data/repo"

cd "$repo"

(
  echo 'dates:'
  git log --tags --simplify-by-decoration --pretty="format:%D: %ai" | sed 's#^HEAD -> master, ##' | sed 's#, origin/master:#:#' | grep -E '^tag: [^ ]+:' | sed 's#^tag: #  #'
) > "$sitedir/data/repo/tags.yml"
