#!/usr/bin/env bash 

if [[ -z $USER ]]; then
    echo "Need console.redhat.com username in \$USER variable"
    exit 1
fi

if [[ -z $PASSWORD ]]; then
    echo "Need console.redhat.com password in \$PASSWORD variable"
    exit 1
fi

# set INPUT in order to read from a different csv - defaulting to "accounts.csv"
INPUT=${INPUT:-accounts.csv}

if [[ ! -f $INPUT ]]; then
    echo "$INPUT not found"
    exit 1
fi

# healthcheck (checking the credentials)
curl -s --fail -u $USER:$PASSWORD https://console.redhat.com/api/sources/v3.1/sources >/dev/null
if [[ $? != 0 ]]; then
    echo "Authentication failed - check your USER/PASSWORD variables."
    exit 1
fi

# do the uploading!
for i in $(cat $INPUT); do
    # skipping the first line (if copied from example.csv)
    if [[ $i == "Name,AccessKey,Secret" ]]; then
        continue
    fi

    name=$(echo $i | cut -d, -f1)
    accesskey=$(echo $i | cut -d, -f2)
    secret=$(echo $i | cut -d, -f3)

    echo Creating $name

    msg=$(cat req.json | \
        sed "s/TNAME/$name/g" | \
        sed "s/TACCESS/$accesskey/g" | \
        sed "s/TSECRET/$secret/g"
    )

    curl --fail -s -XPOST \
        -u $USER:$PASSWORD \
        -d "$msg" \
        https://console.redhat.com/api/sources/v3.1/bulk_create >/dev/null
    
    if [[ $? != 0 ]]; then
        echo "Invalid exit code from sources-api: $?"
        exit 1
    fi
done
