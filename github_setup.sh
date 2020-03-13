#!/bin/bash

cp .ssh/id_rsa ~/.ssh/
cp .ssh/id_rsa.pub ~/.ssh/

sudo chmod 644 ~/.ssh/id_rsa.pub
sudo chmod 700 ~/.ssh/id_rsa

git config --global user.name "Julie Allinson"
git config --global user.email "julie@notch8.com"
git config --global core.excludesfile ~/.gitignore
git config --global core.editor vim

# increase number of inotify watches
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

