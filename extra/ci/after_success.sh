#!/bin/bash

set -e

source ./extra/ci/common.sh

if [[ -n "$COVERAGE" ]]; then
    info coveralls
fi

if [[ -z "$TRAVIS_TAG" && -z "$APPVEYOR_REPO_TAG_NAME" ]]; then
    LABEL=dev
    python extra/ci/bump-beta-version.py $(cat mordred/_version.txt) > mordred/_version.txt
else
    LABEL=main
fi

info conda build . --no-test

OUTPUT=`conda build . --output --python $PYTHON_VERSION`
if [[ -n "$ANACONDA_CLOUD_TOKEN" ]]; then
    if [[ -n "$APPVEYOR" ]]; then
        cmd /c "anaconda -t $ANACONDA_CLOUD_TOKEN upload --label $LABEL --force $OUTPUT"
    else
        anaconda -t $ANACONDA_CLOUD_TOKEN upload --label $LABEL --force $OUTPUT
    fi
fi

# documentation
if [[ -f ~/.ssh/id_rsa && "$TRAVIS_PULL_REQUEST" == false && -n "$DOCUMENTATION" && "$TRAVIS_OS_NAME" == linux ]]; then
    eval $(ssh-agent -s)
    ssh-add
    ssh-add -l
    echo "$SSH_AGENT_PID"

    cd docs
    info make html

    rm -rf gh-pages
    info git clone -b gh-pages $DOC_REMOTE gh-pages
    if [[ -d gh-pages/$TRAVIS_BRANCH ]]; then
        info rm -r gh-pages/$TRAVIS_BRANCH
    fi
    mkdir -p gh-pages/$(dirname $TRAVIS_BRANCH)
    info cp -r _build/html gh-pages/$TRAVIS_BRANCH

    cd gh-pages
    info git add .
    info git commit -m "update documentation to mordred-descriptor/mordred@$TRAVIS_COMMIT"
    info git push origin gh-pages
fi
