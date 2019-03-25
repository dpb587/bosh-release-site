#!/bin/bash

set -eu

rm -fr content data

# this is broken because commit_hash is not valid in recent versions :(

./bin/generate-boshio-artifacts-data.sh github.com/cloudfoundry/bosh
./bin/generate-release-content.sh ~/Projects/src/github.com/cloudfoundry/bosh
./bin/generate-repo-tags-data.sh ~/Projects/src/github.com/cloudfoundry/bosh

hugo serve --disableFastRender
