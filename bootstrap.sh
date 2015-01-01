#!/usr/bin/env bash

sudo apt-get update
sudo apt-get upgrade

# Install MySQL and other dependecies
sudo apt-get install -y git make build-essential nodejs

git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
cd /vagrant
$HOME/.rbenv/bin/rbenv install
$HOME/.rbenv/bin/rbenv rehash
source ~/.bash_profile
sudo gem install bundler
$HOME/.rbenv/bin/rbenv rehash
bundle install