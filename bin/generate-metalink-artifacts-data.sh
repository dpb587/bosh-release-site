#!/bin/bash

set -eu

sitedir="$( realpath "$PWD" )"
meta4repo="$1"

mkdir -p "$sitedir/data/releases"

meta4-repo filter --format=json "$meta4repo" \
  > "$sitedir/data/releases/artifacts.json"
