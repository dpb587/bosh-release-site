#!/bin/bash

set -eu

repo="$1"
remote="${2:-origin}"

cd "$repo"

# avoid stale concourse resource caches
git fetch --tags $( git remote get-url "$remote" | sed 's#git@github.com:#https://github.com/#' )
