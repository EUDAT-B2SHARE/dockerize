#!/bin/bash
#
# This file is part of EUDAT B2Share.
# Copyright (C) 2017 CERN.
#
# B2Share is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# B2Share is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with B2Share; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#
# In applying this license, CERN does not
# waive the privileges and immunities granted to it by virtue of its status
# as an Intergovernmental Organization or submit itself to any jurisdiction.

# Testing script for the upgrade of B2Share 2.0.1 to 2.1.0

# Initialization: make sure that the test_b2share_upgrade.sh script has run
#                 and docker-compose.yml uses the new b2share v2.1.0 image
#                 run `docker-compose up` and then
#                 run this script with passing the access token as an argument again

if [ ! -z "$1" ]
    then
        ACCESS_TOKEN=$1;
else
    echo "An access_token is required for this test."
    exit
fi

# the list of records should include the records from before
get_all_records_output=$(curl -i -k -L --silent -X GET https://localhost/api/records/?access_token=$ACCESS_TOKEN)

# check that the files are there
files_url_tmp=$(grep -Eo 'https://localhost/api/files/[^ >\",]+' <<< $get_all_records_output | head -1)
FILE_BUCKET_ID=$(basename $files_url_tmp)
# echo "bucket id: $FILE_BUCKET_ID"

get_all_files=$(curl -i -k --write-out '%{http_code}' --silent -o /dev/null -L https://localhost/api/files/$FILE_BUCKET_ID?access_token=$ACCESS_TOKEN)
if [ "$get_all_files" != "200" ]
    then
        echo "Get all files from a record: Failed with $get_all_files."
        echo "Make sure that docker-compose up has finished initializing."
        exit
else
    echo "Get all files from a record: Ok."
fi

# create a deposit and try to modify it
rec_create_output=$(curl -i -k -L --silent -H "Content-Type:application/json" \
-d '{"titles":[{"title":"TestRestAfter"}], "community":"e9b9792e-79fb-4b07-b6b4-b9c2bd06d095", "open_access":true, "community_specific": {}}' \
-X POST https://localhost/api/records/?access_token=$ACCESS_TOKEN)

first_line=`echo "${rec_create_output}" | head -1`

if [[ "$first_line" == *"HTTP/1.1 201 CREATED"* ]]
    then
        echo "Draft creation: Ok."
else
    echo "Draft creation: Failed with $first_line."
    exit
fi

records_url_tmp=$(grep -Eo 'https://localhost/api/records/[^ >","]+' <<< $rec_create_output | tail -n2)
RECORD_ID=$(basename $records_url_tmp)
# echo "record id: $RECORD_ID"

# edit the draft's title
modify_metadata=$(curl -i -k -L --write-out '%{http_code}' --silent -o /dev/null -X PATCH -H 'Content-Type:application/json-patch+json' \
-d '[{"op": "replace", "path":"/titles/0/title", "value": "ModifiedTitle"}]' https://localhost/api/records/$RECORD_ID/draft?access_token=$ACCESS_TOKEN)
if [ "$modify_metadata" != "200" ]
    then
        echo "Draft editing: Failed with $modify_metadata."
        exit
else
    echo "Draft editing: Ok."
fi

# the API should have the stats endpoint
get_stats_output=$(curl -i -k -L --write-out '%{http_code}' --silent -o /dev/null -X POST https://localhost/api/stats -d {"mystat":{"date-histogram"}})
if [ "$get_stats_output" != "200" ]
    then
        echo "Stats querying: Failed with $get_stats_output."
        exit
else
    echo "Stats querying: Ok."
fi

echo "Upgrade test complete."
