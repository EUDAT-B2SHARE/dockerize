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

# Initialization: edit the docker-compose.yml file to use the b2share image 2.0.1
#                 ...
#                 b2share:
#                     image: eudatb2share/b2share:2.0.1
#                 ...
#                 and then run: `docker-compose up`
#                 after logging go to your profile page and create an application token
#                 copy the generated token and call this script with it e.g.:
#                 `./test_b2share_upgrade.sh uRspBhVKQXGtkjkT3ww0ioIZuIsM2HRDbIIa5sVXgDeUrqvoVrILPiA5WWR6`

if [ ! -z "$1" ]
    then
        ACCESS_TOKEN=$1;
else
    echo "An access_token is required for this test."
    exit
fi

# create a draft using the REST API
rec_create_output=$(curl -i --silent -k -L -H "Content-Type:application/json" \
-d '{"titles":[{"title":"TestRest"}], "community":"e9b9792e-79fb-4b07-b6b4-b9c2bd06d095", "open_access":true, "community_specific": {}}' \
-X POST https://localhost/api/records/?access_token=$ACCESS_TOKEN)

first_line=`echo "${rec_create_output}" | head -1`

# make sure that it was created with a status code 201
if [[ "$first_line" == *"HTTP/1.1 201 CREATED"* ]]
    then
        echo "Draft creation: Ok."
else
    echo "Draft creation: Failed with $rec_create_output."
    echo "Make sure that docker-compose up has finished initializing."
    exit
fi

# parse the generated file id and record id
files_url_tmp=$(grep -Eo 'https://localhost/api/files/[^ >;]+' <<< $rec_create_output | head -1)
FILE_BUCKET_ID=$(basename $files_url_tmp)
# echo "bucket id: $FILE_BUCKET_ID"

records_url_tmp=$(grep -Eo 'https://localhost/api/records/[^ >","]+' <<< $rec_create_output | tail -n2)
RECORD_ID=$(basename $records_url_tmp)
# echo "record id: $RECORD_ID"

# upload a file to the draft
# echo "Uploading file to $FILE_BUCKET_ID"
echo "test_data" > test_file.txt
upload_file_output=$(curl -X PUT -k -L --write-out '%{http_code}' --silent -o /dev/null -H 'Accept:application/json' -H 'Content-Type:application/octet-stream' \
 -d @test_file.txt \
 https://localhost/api/files/$FILE_BUCKET_ID/test_file.txt?access_token=$ACCESS_TOKEN)

if [ "$upload_file_output" != "200" ]
    then
        echo "File upload: Failed with #upload_file_output."
        exit
else
    echo "File upload: Ok."
fi

# edit the draft
modify_metadata=$(curl -k -L --write-out '%{http_code}' --silent -o /dev/null -X PATCH -H 'Content-Type:application/json-patch+json' \
-d '[{"op": "replace", "path":"/titles/0/title", "value": "ModifiedTitle"}]' https://localhost/api/records/$RECORD_ID/draft?access_token=$ACCESS_TOKEN)

if [ "$modify_metadata" != "200" ]
    then
        echo "Draft editing: Failed with $modify_metadata."
        exit
else
    echo "Draft editing: Ok."
fi

# publish the draft so that the record is public
publish_output=$(curl -k -L --write-out '%{http_code}' --silent -o /dev/null -X PATCH -H 'Content-Type:application/json-patch+json' \
 -d '[{"op": "add", "path":"/publication_state", "value": "submitted"}]' \
 https://localhost/api/records/$RECORD_ID/draft?access_token=$ACCESS_TOKEN)

if [ "$publish_output" != "200" ]
    then
        echo "Record publishing: Failed with $publish_output."
        exit
else
    echo "Record publishing: Ok."
fi

echo "Setup complete.
Stop docker with docker-compose down,
swap the image of b2share to the version 2.1.0
and start it again with docker-compose up.
Run the test_after_upgrade.sh in the same way."
