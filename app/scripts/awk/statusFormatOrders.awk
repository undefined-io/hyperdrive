#!/usr/bin/awk -f
# input: _default/orders git@github.com:undefined-io/website.git
# output: order:[_default] git@github.com:undefined-io/website.git
function green(string) {
  printf(" [%s%s%s] ", "\033[0;32m", string, "\033[0m");
}
{
  gsub(/\/orders$/, "", $1);
  printf "order:";
  green($1);
  print $2;
}
