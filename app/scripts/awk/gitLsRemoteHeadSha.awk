#!/usr/bin/awk -f
# take 'git ls-remote' and pull the sha for the HEAD
{
  if ($2 == "HEAD") {
    print $1
  }
}
