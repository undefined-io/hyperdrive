#!/usr/bin/awk -f
# retrieve the first remote repo url (source: git remote -v)
NR==1 && /^origin/ {
  print $2;
  exit;
}
