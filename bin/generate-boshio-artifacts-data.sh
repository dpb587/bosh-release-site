#!/bin/bash

set -eu

sitedir="$( realpath "$PWD" )"
repo="$1"

mkdir -p "$sitedir/data/releases"

wget -qO- "https://bosh.io/api/v1/releases/$repo" \
  | jq \
    '
      {
        "metalink": map({
          "files": [
            {
              "hashes": [
                {
                  "type": "sha-1",
                  "hash": .sha1
                }
              ],
              "urls": [
                {
                  url
                }
              ],
              version
            }
          ]
        })
      }
    ' \
  > "$sitedir/data/releases/artifacts.json"
