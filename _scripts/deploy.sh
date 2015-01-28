#!/bin/bash
if [[ $TRAVIS_BRANCH == 'master' ]] ; then
	bundle exec rake deploy
fi
