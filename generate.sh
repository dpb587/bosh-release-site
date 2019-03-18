#!/usr/bin/env bash

set -eu

pwd=$PWD
gitroot=$( realpath "$1" )
artifactroot=$( realpath "$2" )
buildroot=$( mkdir -p "$3" ; realpath "$3" )

dataroot="$buildroot/data"
mkdir -p "$dataroot"

meta4-repo filter --format=json "file://$artifactroot/release/stable" \
  > "$dataroot/sourceRelease.json"

contentroot="$buildroot/content"
mkdir -p "$contentroot"

cd "$gitroot"

git checkout --quiet master

for tag in $( git tag -l | grep ^v | gsort -rV ); do
  echo "==> $tag"

  git checkout --quiet master

  semver=$( echo "$tag" | sed 's/^v//' )
  semver_major=$( echo "$semver" | cut -f1 -d. )
  semver_minor=$( echo "$semver" | cut -f2 -d. )
  semver_patch=$( echo "$semver" | cut -f3 -d. )

  release_yml=$( echo releases/*/*-$semver.yml )
  cp "$release_yml" /tmp/release.yml

  release_name=$( bosh interpolate --path=/name "$release_yml" )
  release_version=$( bosh interpolate --path=/version "$release_yml" )
  commit_hash_raw=$( bosh interpolate --path=/commit_hash "$release_yml" )
  commit_hash=$( echo "$commit_hash_raw" | sed 's/+$//' )

  if [[ ! -e "$contentroot/$semver_major.x" ]]; then
    if [[ -e docs ]]; then
      cp -rp docs "$contentroot/$semver_major.x"

      # always include release list
      cat >> $contentroot/$semver_major.x/_menu.md <<EOF

<br />

{{% release/menu %}}
EOF

      # begin: optional content migration
      find "$contentroot/$semver_major.x" -name '*.md' \
        | xargs -n1 \
        -- sed -i'' -E \
          -e 's#\[contributing\]\(../CONTRIBUTING.md\)#[contributing](https://github.com/dpb587/openvpn-bosh-release/blob/master/CONTRIBUTING.md)#' \
          -e 's#\]\(([^:)]+\.md)\)#]({{< relref "\1" >}})#g'

      for readme in $( find "$contentroot/$semver_major.x" -name 'README.md' ); do
        mv "$readme" "$( dirname "$readme" )/_index.md"
      done
      # end: optional content migration
    fi
  fi

  if [[ ! -e "$contentroot/$semver_major.x" ]]; then
    mkdir -p "$contentroot/$semver_major.x"
  fi

  mkdir -p "$contentroot/$semver_major.x/release/$tag"

  file="$contentroot/$semver_major.x/release/$tag/_index.md"

  cat > "$file" <<EOF
---
bosh_release_name: "$release_name"
bosh_release_version: "$release_version"
bosh_release_spec:
$( cat "$release_yml" | sed 's/^/  /' )
bosh_release_spec_raw: |
$( cat "$release_yml" | sed 's/^/  /' )
ordering: $( printf "%03s" "$semver_major" "$semver_minor" "$semver_patch" | sed -E 's/^0+//' )
title: v$semver
---

EOF

  release_md=$( echo "$release_yml" | sed 's/.yml$/.md/' )
  if [[ -e "$release_md" ]]; then
    cat "$release_md" >> "$file"
  fi

  git checkout --quiet "$commit_hash"

  go run $pwd/dump-version-section.go "/tmp/release.yml" "$contentroot/$semver_major.x/release/$tag"
done
