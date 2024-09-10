#!/bin/bash
set -ex

# Fetch updates
git fetch origin dev
git checkout dev
git pull --ff-only

# Initialize git submodules
git submodule update --init --recursive


# Set up (ssh) push access for submodules
pushd Crewgrensesnitt/ > /dev/null
    git remote set-url --push origin git@github.com:EventAccess/Crewgrensesnitt.git
    pushd database/ > /dev/null
        git remote set-url --push origin git@github.com:EventAccess/django-app-database.git
    popd > /dev/null
popd > /dev/null

pushd Registrering/ > /dev/null
    git remote set-url --push origin git@github.com:EventAccess/Registrering.git
    pushd database/ > /dev/null
        git remote set-url --push origin git@github.com:EventAccess/django-app-database.git
    popd > /dev/null
popd > /dev/null

pushd Foreldregrensesnitt > /dev/null
    git remote set-url --push origin git@github.com:EventAccess/Foreldregrensesnitt.git
popd > /dev/null

pushd NFCScanner/ > /dev/null
    git remote set-url --push origin git@github.com:EventAccess/NFCScanner.git
popd > /dev/null

pushd Crew-Discord-Bot/ > /dev/null
    git remote set-url --push origin git@github.com:EventAccess/Crew-Discord-Bot.git
popd > /dev/null


# TODO: Set up pre-commit
