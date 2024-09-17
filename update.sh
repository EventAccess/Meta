#!/bin/bash
set -ex

# Fetch updates
git fetch origin dev
git checkout dev
git pull --ff-only

# Initialize git submodules
git submodule update --init --recursive


# Set up (ssh) push access for submodules
function ensure_ssh_push_submodules() {
    if test -f .gitmodules; then
        IN=$(sed -Ezn 's!\[submodule\ "[^"]+"\].*?(\s*(path\s*=\s*([^\n]+)|url\s*=\s*([^\n]+))){2}!\3\t\4!gmp' .gitmodules)

        while IFS= read -r line; do
            IFS=$'\t' read -ra LINE <<< "${line[@]}"
            dir="${LINE[0]}"
            url="${LINE[1]}"

            newurl=$(sed -E 's!https?://github.com/!git@github.com:!g' <<< "${url}")
            pushd "${dir}" > /dev/null
                git remote set-url --push origin "${newurl}"
                default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
                git fetch origin "${default_branch}"
                git checkout "${default_branch}"
                git pull --ff-only
                ensure_ssh_push_submodules
            popd > /dev/null
        done <<< "${IN[@]}"
    fi
}

ensure_ssh_push_submodules

# TODO: Set up pre-commit
