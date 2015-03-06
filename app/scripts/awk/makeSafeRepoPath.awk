#!/usr/bin/awk -f
# https://github.com/undefined-io/hyperdrive#master > undefined-io..hyperdrive..master
BEGIN {
  FS="/";
}
{
  OWNER=$(NF-1);
  REPO_BRANCH=$(NF);
  sub(/#/, "..", REPO_BRANCH)
  print OWNER ".." REPO_BRANCH
}
