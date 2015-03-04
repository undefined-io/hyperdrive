#!/usr/bin/awk -f
# extract order from HQ path
BEGIN {
  FS="/";
}
{
  print $(NF-1)
}
