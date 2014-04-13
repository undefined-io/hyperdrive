#!/usr/bin/env bash
until ifconfig | grep 'inet addr' | grep --invert '127.0.0.1' > /dev/null
do
  sleep 0.1
done
echo -e "\n127.0.0.1    $(< /etc/hostname)" >> /etc/hosts
# TODO: assign to admin group instead?
echo -e "\nubuntu ALL=NOPASSWD:ALL" >> /etc/sudoers
apt-get -y update
apt-get -y install --force-yes $(< "/var/starphleet/share/lxc-base.packages")
