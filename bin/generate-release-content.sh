#!/bin/bash

set -eu

sitedir="$( realpath "$PWD" )"
repo="$1"

cd "$repo"

mkdir -p "$sitedir/tmp"

git checkout --quiet master

for release_yml in $( ls releases/*/*.yml | grep -v index.yml | sort -rV ); do
  echo "==> $release_yml"

  version=$( bosh interpolate --path=/version "$release_yml" )
  commit_hash=$( bosh interpolate --path=/commit_hash "$release_yml" )

  cp "$release_yml" "$sitedir/tmp/release.yml"

  git checkout --quiet "$commit_hash"

  go run $sitedir/src/generate-release-version-content.go "$sitedir/tmp/release.yml" "$sitedir/content"

  git checkout --quiet master

  ( cat "${release_yml%.*}.md" || true ) >> ../site/content/releases/v$version/_index.md
done
#
# mkdir ../site/content/docs
#
# cp -rp docs ../site/content/docs/latest
#
# ../site/bin/generate-data.sh ../repo ../artifacts/release/stable ../site
