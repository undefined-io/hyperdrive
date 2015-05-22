#!/usr/bin/env bash

# This script is meant to run inside of a hyperdrive workstation

set -o nounset; set -o errexit
until ifconfig | grep 'inet addr' | grep --invert '127.0.0.1' > /dev/null
do
  sleep 0.1
done
echo -e "\n127.0.0.1    $(< /etc/hostname)" >> /etc/hosts

# determine correct buildpack for the application
SELECTED_BUILDPACK=""
echo "[.] running buildpack detect"
for BUILDPACK in $(find /var/hyperdrive/buildpacks -mindepth 1 -maxdepth 1 -type d); do
  echo "[.] .. ${BUILDPACK}"
  $BUILDPACK/bin/detect "/var/hyperdrive/share/app" > /dev/null 2>&1 || continue
  SELECTED_BUILDPACK=$BUILDPACK && break
done
if [[ -n "${SELECTED_BUILDPACK}" ]]; then
  echo "[.] ${SELECTED_BUILDPACK}"
else
  echo "[X] could not find buildpack"
  exit 1
fi

APP_HOME="/home/ubuntu"
APP_ROOT="${APP_HOME}/app"
BUILDPACK_ROOT="${APP_HOME}/buildpack"

# create the build script
cat << BUILDEOF > "${APP_HOME}/build.sh"
#!/usr/bin/env bash
set -o nounset; set -o errexit
cd
sudo rm -rf ${APP_ROOT}
sudo rsync -az --exclude '.git' "/var/hyperdrive/share/app/" "${APP_ROOT}"
sudo rsync -az --exclude '.git' "${SELECTED_BUILDPACK}/" "${BUILDPACK_ROOT}"
sudo chown -R ubuntu:ubuntu ${APP_HOME}

# compile the buildpack for the application
export REQUEST_ID=$(openssl rand -base64 32)
"${BUILDPACK_ROOT}/bin/compile" "${APP_ROOT}" "/tmp/donotcache"
"${BUILDPACK_ROOT}/bin/release" "${APP_ROOT}" > "${APP_ROOT}/.release"

cat << STARTEOF > "${APP_HOME}/start.sh"
#!/usr/bin/env bash
cd "${APP_ROOT}"
export HOME="${APP_ROOT}"
for FILE in .profile.d/*; do source "\\\$FILE"; done
env | sort
STARTEOF
if [[ -f "${APP_ROOT}/Procfile" ]]; then
  ruby -e "require 'yaml';puts YAML.load_file('${APP_ROOT}/Procfile')['web']" >> "${APP_HOME}/start.sh"
else
  ruby -e "require 'yaml';puts (YAML.load_file('${APP_ROOT}/.release')['default_process_types'] || {})['web']" >> "${APP_HOME}/start.sh"
fi
chmod 744 "${APP_HOME}/start.sh"

sudo touch "/var/hyperdrive/share/build.completed"
BUILDEOF

chown ubuntu:ubuntu "${APP_HOME}/build.sh"
chmod 744 "${APP_HOME}/build.sh"

touch  /var/hyperdrive/share/setup.completed
