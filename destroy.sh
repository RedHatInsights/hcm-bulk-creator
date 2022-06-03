#!/usr/bin/env bash

# check to see if we have enough variables
source healthcheck.sh

for i in $(cat $INPUT); do
    # skipping the first line (if copied from example.csv)
    if [[ $i == "Name,AccessKey,Secret" ]]; then
        continue
    fi

    name=$(echo $i | cut -d, -f1)

    echo Destroying $name

    id=$(curl --fail -s -XGET \
        -u $USER:$PASSWORD \
        "https://console.redhat.com/api/sources/v3.1/sources?name=$name" \
    | jq -r .data[0].id)

    if [[ $? != 0 ]]; then
        echo "Error fetching source $name"
        echo "Invalid exit code from sources-api: $?"
        exit 1
    fi

    if [[ $id == "null" ]]; then
        echo "Source not found: $name"
        exit 1
    fi

    curl --fail -s -XDELETE \
        -u $USER:$PASSWORD \
        "https://console.redhat.com/api/sources/v3.1/sources/$id"

    if [[ $? != 0 ]]; then
        echo "Error deleting source $id"
        echo "Invalid exit code from sources-api: $?"
        exit 1
    fi

done
