#!/usr/bin/awk -f
# parse hyperdrive jobs from initctl list
BEGIN {
  FS="[ ()]+";
}
{
  if ($1 ~ /^hyperdrive-assignment/) {
    print $2
  } 
}
