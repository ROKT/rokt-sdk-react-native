#!/bin/bash

cd ./RoktSampleApp
sudo apt install curl
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs 
npm install
cd ./android
bundle install
exit 0

