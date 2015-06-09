#!/usr/bin/awk -f
# parse hyperdrive jobs from initctl list
/^hyperdrive/ {print "job  :",$0}
