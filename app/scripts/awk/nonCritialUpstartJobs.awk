#!/usr/bin/awk -f
# takes 'initctl list' and returns list of upstart jobs that are able to be stopped during hyperdrive updates
{
  if ($1 ~ /hyperdrive-(nginx|assignment)/) {
  } else if ($1 ~ /^hyperdrive-/) {
    print $1
  }
}
