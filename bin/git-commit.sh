#!/bin/bash

repo="$1"

cd "$repo"

export GIT_AUTHOR_DATE="2001-01-01T01:01:01Z"
export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"

git config --global user.email "${GIT_AUTHOR_EMAIL:-ci@localhost}"
git config --global user.name "${GIT_AUTHOR_NAME:-CI Bot}"
git init
git add .
git commit -m 'build docs'
