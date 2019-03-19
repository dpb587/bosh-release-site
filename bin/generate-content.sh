#!/usr/bin/env bash

set -eu

pwd=$PWD
reporoot=$( realpath "$1" )
buildroot=$( mkdir -p "$2" ; realpath "$2" )
docsURL="$3"
repositoryURL="$4"

contentroot="$buildroot/content"
mkdir -p "$contentroot"

configroot="$buildroot/config"
mkdir -p "$configroot"

publicroot="$buildroot/public"
mkdir -p "$publicroot"

cd "$reporoot"

git checkout --quiet master

latest_version=""

for release_yml in $( ls releases/*/*.yml | grep -v index.yml | gsort -rV ); do
  echo "==> $release_yml"

  git checkout --quiet master

  release_name=$( bosh interpolate --path=/name "$release_yml" )
  release_version=$( bosh interpolate --path=/version "$release_yml" )
  commit_hash_raw=$( bosh interpolate --path=/commit_hash "$release_yml" )
  commit_hash=$( echo "$commit_hash_raw" | sed 's/+$//' )

  tag=v$release_version
  semver_major=$( echo "$release_version" | cut -f1 -d. )
  semver_minor=$( echo "$release_version" | cut -f2 -d. )
  semver_patch=$( echo "$release_version" | cut -f3 -d. )

  if [[ -z "$latest_version" ]]; then
    latest_version=$release_version
  fi

  if [[ ! -e "$contentroot/$semver_major.x" ]]; then
    if [[ -e docs ]]; then
      cp -rp docs "$contentroot/$semver_major.x"

      # always include release list
      cat >> $contentroot/$semver_major.x/_menu.md <<EOF

<br />

{{% release/menu %}}
EOF
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
$( cat "$release_yml" | sed -e 's/^---//' -e 's/^/  /' )
bosh_release_spec_raw: |
$( cat "$release_yml" | sed 's/^/  /' )
ordering: $( printf "%03s" "$semver_major" "$semver_minor" "$semver_patch" | sed -E 's/^0+//' )
title: "v$semver"
type: "bosh-release"
---

EOF

  release_md=$( echo "$release_yml" | sed 's/.yml$/.md/' )
  if [[ -e "$release_md" ]]; then
    cat "$release_md" >> "$file"
  fi

  git checkout --quiet "$commit_hash"

  go run $pwd/src/dump-version-section.go <( git show master -- $release_yml ) "$contentroot/$semver_major.x/release/$tag"

cat > $configroot/$semver_major.x.yml <<EOF
title: "$release_name/$semver_major.x"
params:
  boshReleaseName: $release_name
  boshReleaseVersionLatest: $latest_version
  boshRepo: "$repositoryURL"
  boshBlobPath: "blob/$tag"
EOF
done
