#!/bin/bash

cp .ssh/id_rsa ~/.ssh/
cp .ssh/id_rsa.pub ~/.ssh/

sudo chmod 644 ~/.ssh/id_rsa.pub
sudo chmod 700 ~/.ssh/id_rsa

git config --global user.name "Julie Allinson"
git config --global user.email "julie.allinson@london.ac.uk"

git config --global core.excludesfile ~/.gitignore

