#!/usr/bin/awk -f
# skip the first two lines of output and print the IP
# TODO: Is there a better way to trim strings?
NR > 2 { print $1 }
