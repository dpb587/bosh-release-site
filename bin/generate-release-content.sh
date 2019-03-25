#!/bin/bash

set -eu

sitedir="$( realpath "$PWD" )"
repo="$1"

go build -o bin/generate-release-version-content ./src/generate-release-version-content.go

cd "$repo"

mkdir -p "$sitedir/tmp"

git checkout --quiet master

for release_yml in $( ls releases/*/*.yml | grep -v index.yml | sort -rV ); do
  echo "==> $release_yml"

  version=$( bosh interpolate --path=/version "$release_yml" )
  commit_hash=$( bosh interpolate --path=/commit_hash "$release_yml" )

  cp "$release_yml" "$sitedir/tmp/release.yml"

  git checkout --quiet "$commit_hash" || continue

  "$sitedir/bin/generate-release-version-content" "$sitedir/tmp/release.yml" "$sitedir/content"

  git checkout --quiet master

  release_md="${release_yml%.*}.md"

  if [[ -e "$release_md" ]]; then
    cat "$release_md" >> "$sitedir/content/releases/v$version/_index.md"
  fi
done
