#!/bin/bash
set -ex

# Update default branch
function update_default_branch() {
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    current_branch=$(git branch --show-current)

    # if on default branch or detached HEAD
    if [ "$current_branch" = "$default_branch" ] || [ -z "$current_branch" ]; then
        # We are on dev branch, fast-forward it
        git fetch origin "${default_branch}"
        git checkout "${default_branch}"

        # if pull failed and we are in detached HEAD with local changes, abort
        if ! git pull --ff-only origin "${default_branch}" \
        && [ -z "$current_branch" ] \
        && [ -n "$(git status --porcelain --ignore-submodules=dirty)" ]; then
            # Not sure exactly how this happened,
            # possibly due to failed dev:dev fetch in an earlier iteration.
            echo
            pwd
            echo
            git status --porcelain --ignore-submodules=dirty
            echo
            echo "!!! ERROR !!! Detached HEAD with local changes & failed to fast-forward, aborting."
            echo "Tell Odd."
            echo
            exit 1
        fi
    else
        # Fast-forward dev branch without switching to it
        git fetch origin "${default_branch}:${default_branch}"
    fi
}



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

                update_default_branch

                ensure_ssh_push_submodules
            popd > /dev/null
        done <<< "${IN[@]}"
    fi
}


# Fetch updates
update_default_branch

# Initialize git submodules
git submodule update --init --recursive

ensure_ssh_push_submodules

# TODO: Set up pre-commit
# Issue URL: https://github.com/EventAccess/Meta/issues/18

# TODO: Prune merged branches
# Issue URL: https://github.com/EventAccess/Meta/issues/22
#   git branch --merged | grep -Ev "(^\*|^\+|^\s*(master|main|dev)\s*$)" | xargs --no-run-if-empty git branch -d
