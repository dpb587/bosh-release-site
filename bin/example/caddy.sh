#!/bin/bash

set -eu

repo="$HOME/Projects/src/github.com/dpb587/caddy-bosh-release"

rm -fr content data static

mkdir -p static/img

wget -qO static/img/dpb587.jpg https://dpb587.me/images/dpb587-20140313a~256.jpg

./bin/generate-metalink-artifacts-data.sh "git+https://github.com/dpb587/caddy-bosh-release.git//release/stable#artifacts"
./bin/generate-release-content.sh "$repo"
./bin/generate-repo-tags-data.sh "$repo"

mkdir -p content/docs

cp -rp "$repo/docs" content/docs/latest

./bin/remap-docs-contribute-links.sh docs/latest docs

cat > config.local.yml <<EOF
title: caddy-bosh-release
params:
  ThemeBrandIcon: /img/dpb587.jpg
  ThemeNavItems:
  - title: docs
    url: docs/latest
  - title: releases
    url: releases
  - title: github
    url: &github "https://github.com/dpb587/caddy-bosh-release"
  ThemeNavBadges:
  - title: BOSH
    color: "#fff"
    img: img/cff-bosh.png
    url: https://bosh.io/
  RequireContributeLinkMap: true
  CopyrightNotice: |
    [Caddy BOSH Release](https://github.com/dpb587/caddy-bosh-release) by [Danny Berger](https://dpb587.me/).
  GitRepo: *github
  GitEditPath: blob/master
  GitCommitPath: commit
  boshReleaseName: caddy
  boshReleaseVersion: "$( cd content/releases ; ls | grep ^v | sed 's/^v//' | $( which gsort || echo "sort" ) -rV | head -n1 )"
EOF

hugo --config config.yml,config.local.yml
