#!/bin/bash
if [[ $TRAVIS_BRANCH == 'master' ]] ; then
	rake deploy
fi
