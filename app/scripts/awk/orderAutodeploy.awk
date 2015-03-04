#!/usr/bin/awk -f
# retrieve repo url from last autodeploy line
/^autodeploy[ \t]*/ {repo=$2}
END {print repo}
