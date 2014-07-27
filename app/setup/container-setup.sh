#!/usr/bin/env bash

# This script is meant to run inside of a starphleet container

set -o nounset; set -o errexit
until ifconfig | grep 'inet addr' | grep --invert '127.0.0.1' > /dev/null
do
  sleep 0.1
done
echo -e "\n127.0.0.1    $(< /etc/hostname)" >> /etc/hosts

# TODO: assign to admin group instead?
echo -e "\nubuntu ALL=NOPASSWD:ALL" >> /etc/sudoers
apt-get -y update
apt-get -y install --force-yes $(< "/var/starphleet/share/lxc-base.packages")

touch  /var/starphleet/share/setup.completed
