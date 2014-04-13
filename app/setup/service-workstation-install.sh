#!/usr/bin/env bash
set -o nounset; set -o errexit
until ifconfig | grep 'inet addr' | grep --invert '127.0.0.1' > /dev/null
do
  sleep 0.1
done
echo -e "\n127.0.0.1    $(< /etc/hostname)" >> /etc/hosts

for BUILDPACK in $(find /var/starphleet/buildpacks -mindepth 1 -maxdepth 1 -type d); do
  echo ${BUILDPACK}
  buildpack_name=$($BUILDPACK/bin/detect "$build_root") && selected_buildpack=$BUILDPACK && break
done
