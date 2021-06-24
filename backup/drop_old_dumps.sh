#!/bin/bash
#
# Drop old database dumps.

/usr/bin/find /usr/local/share/pgsql_dumps -type f -mtime +${NUMBER_OF_DUMPS} -delete

