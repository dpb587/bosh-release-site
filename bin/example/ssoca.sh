#!/bin/bash

set -eu

rm -fr content data

./bin/generate-metalink-artifacts-data.sh "git+https://github.com/dpb587/ssoca-bosh-release.git//release/stable#artifacts"
./bin/generate-release-content.sh ~/Projects/src/github.com/dpb587/ssoca-bosh-release
./bin/generate-repo-tags-data.sh ~/Projects/src/github.com/dpb587/ssoca-bosh-release

hugo serve --disableFastRender
