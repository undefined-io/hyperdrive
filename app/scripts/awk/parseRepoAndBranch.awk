#!/usr/bin/awk -f
# create two separate strings with repo and branch
BEGIN {
  FS="#";
}
{
  gsub(/\r/, "")
  print $1 " " $2
}
