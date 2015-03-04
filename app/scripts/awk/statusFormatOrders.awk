#!/usr/bin/awk -f
# input: _default/orders order: git@github.com:undefined-io/website.git
# output: order:[_default] git@github.com:undefined-io/website.git
function green(string) {
  printf(" [%s%s%s] ", "\033[1;32m", string, "\033[0m");
}
{
  gsub(/\/orders$/, "", $1);
  printf $2;
  green($1);
  print $3;
}
