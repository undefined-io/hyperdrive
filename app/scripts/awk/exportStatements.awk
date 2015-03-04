#!/usr/bin/awk -f
# all export statements
/^[ \t]*export[ \t]+/ {print $0}
