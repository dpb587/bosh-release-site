#!/bin/bash

set -eu

rm -fr content data

# this is broken because commit_hash is not valid

./bin/generate-boshio-artifacts-data.sh github.com/concourse/concourse-bosh-release
./bin/generate-release-content.sh ~/Projects/src/github.com/concourse/concourse-bosh-release
./bin/generate-repo-tags-data.sh ~/Projects/src/github.com/concourse/concourse-bosh-release

hugo serve --disableFastRender
