#!/usr/bin/gawk -f
# filter 'git ls-remote' based on REMOTE_HEAD_SHA environment variable, and return the default branch
{
  if ($1 == ENVIRON["REMOTE_HEAD_SHA"] && $2 != "HEAD") {
    gsub(/refs\/(heads|tags)\//, "", $2);
    print $2
    exit;
  }
}
