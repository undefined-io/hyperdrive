#!/usr/bin/env bash

# This script is meant to run inside of a hyperdrive workstation

set -o nounset; set -o errexit
until ifconfig | grep 'inet addr' | grep --invert '127.0.0.1' > /dev/null
do
  sleep 0.1
done
echo -e "\n127.0.0.1    $(< /etc/hostname)" >> /etc/hosts

# determine correct buildpack for the assignment
SELECTED_BUILDPACK=""
echo "[.] running buildpack detect"
for BUILDPACK in $(find /var/hyperdrive/buildpacks -mindepth 1 -maxdepth 1 -type d); do
  echo "[.] .. ${BUILDPACK}"
  $BUILDPACK/bin/detect "/var/hyperdrive/share/assignment" > /dev/null 2>&1 || continue
  SELECTED_BUILDPACK=$BUILDPACK && break
done
if [[ -n "${SELECTED_BUILDPACK}" ]]; then
  echo "[.] ${SELECTED_BUILDPACK}"
else
  echo "[X] could not find buildpack"
  exit 1
fi

SHIP_HOME="/home/ubuntu"
ASSIGNMENT_HOME="${SHIP_HOME}/assignment"
BUILDPACK_ROOT="${SHIP_HOME}/buildpack"

# create the build script
cat << BUILDEOF > "${SHIP_HOME}/build.sh"
#!/usr/bin/env bash
set -o nounset; set -o errexit
cd
sudo rm -rf ${ASSIGNMENT_HOME}
sudo rsync -az --exclude '.git' "/var/hyperdrive/share/assignment/" "${ASSIGNMENT_HOME}"
sudo rsync -az --exclude '.git' "${SELECTED_BUILDPACK}/" "${BUILDPACK_ROOT}"
sudo chown -R ubuntu:ubuntu ${SHIP_HOME}

# compile the buildpack for the assignment
export REQUEST_ID=$(openssl rand -base64 32)
# start: buildpack hack for python
sudo mkdir /app
sudo chown ubuntu:ubuntu /app
# end: buildpack hack for python
"${BUILDPACK_ROOT}/bin/compile" "${ASSIGNMENT_HOME}" "/tmp/donotcache"
# start: buildpack hack for python
sudo rm -rf "/app"
sudo ln -s "${ASSIGNMENT_HOME}" "/app"
# end: buildpack hack for python
"${BUILDPACK_ROOT}/bin/release" "${ASSIGNMENT_HOME}" > "${ASSIGNMENT_HOME}/.release"

cat << STARTEOF > "${SHIP_HOME}/start.sh"
#!/usr/bin/env bash
cd "${ASSIGNMENT_HOME}"
export HOME="${ASSIGNMENT_HOME}"
for FILE in .profile.d/*; do source "\\\$FILE"; done
env | sort
STARTEOF
if [[ -f "${ASSIGNMENT_HOME}/Procfile" ]]; then
  ruby -e "require 'yaml';puts YAML.load_file('${ASSIGNMENT_HOME}/Procfile')['web']" >> "${SHIP_HOME}/start.sh"
else
  ruby -e "require 'yaml';puts (YAML.load_file('${ASSIGNMENT_HOME}/.release')['default_process_types'] || {})['web']" >> "${SHIP_HOME}/start.sh"
fi
chmod 744 "${SHIP_HOME}/start.sh"

sudo touch "/var/hyperdrive/share/build.completed"
BUILDEOF

chown ubuntu:ubuntu "${SHIP_HOME}/build.sh"
chmod 744 "${SHIP_HOME}/build.sh"

touch  /var/hyperdrive/share/setup.completed
