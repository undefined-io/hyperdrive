#!/usr/bin/awk -f
# all hyperdrive related export staments in orders
/^[ \t]*export[ \t]+(PORT|PUBLISH_PORT|PUBLISH_HOST|PUBLISH_ROOT|PUBLISH_PORT_SSL|REDIRECT_HOST)[ \t]*=/ {print $0}
