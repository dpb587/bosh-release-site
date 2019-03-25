#!/bin/bash

set -eu

sitedir="$( realpath "$PWD" )"
from="$1"
to="$2"

cd "content/$from"

find . | cut -c2- | xargs -I{} -n1 -- /bin/sh -c "echo '$from{}: $to{}'" \
  >> "$sitedir/data/contributeLinks.yml"
