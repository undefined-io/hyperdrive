#!/usr/bin/env bash
set -o nounset; set -o errexit
until ifconfig | grep 'inet addr' | grep --invert '127.0.0.1' > /dev/null
do
  sleep 0.1
done
echo -e "\n127.0.0.1    $(< /etc/hostname)" >> /etc/hosts

# determine correct buildpack for the application
SELECTED_BUILDPACK=""
echo "[.] running buildpack detect"
for BUILDPACK in $(find /var/starphleet/buildpacks -mindepth 1 -maxdepth 1 -type d); do
  echo "[.] .. ${BUILDPACK}"
  $BUILDPACK/bin/detect "/var/starphleet/share/app" > /dev/null 2>&1 || continue
  SELECTED_BUILDPACK=$BUILDPACK && break
done
if [[ -n "${SELECTED_BUILDPACK}" ]]; then
  echo "[.] ${SELECTED_BUILDPACK}"
else
  echo "[X] could not find buildpack"
  exit 1
fi

cat << EOF > /home/ubuntu/build.sh
set -o nounset; set -o errexit
cd
sudo rm -rf ./app/
sudo rsync -az --exclude '.git' "/var/starphleet/share/app/" app
sudo chown -R ubuntu:ubuntu ./app/

# compile the buildpack for the application
export REQUEST_ID=$(openssl rand -base64 32)
"${SELECTED_BUILDPACK}/bin/compile" "/home/ubuntu/app" "/tmp/donotcache"

sudo touch "/var/starphleet/share/build.completed"
EOF
chown ubuntu:ubuntu /home/ubuntu/build.sh
chmod 744 /home/ubuntu/build.sh
touch  /var/starphleet/share/setup.completed