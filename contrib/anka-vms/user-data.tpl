#!/bin/bash 
# get the list of installers
softwareupdate --list-full-installers
# install the latest version, such as 12.4, 12.3.1, etc.
softwareupdate --fetch-full-installer --full-installer-version ${VERSION}
#
sudo /usr/bin/dscl . -passwd /Users/ec2-user zbun0ok= ${NEW_PASSWORD}