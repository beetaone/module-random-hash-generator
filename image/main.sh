#!/bin/bash

while true; do

    # Collect bytes and hash them
    case $hash in
    md5)
        # Get 4096 bytes of random data. Take the hash. Do not keep the dash after the string. Assign to variable.
        randomstring=$(head -n 4096 $VOLUME_CONTAINER | md51sum | cut -f 1 -d " ")
        echo -e "\ndev-random generated random SHA1 hash $randomstring from host"
        ;;
    sha1)
        randomstring=$(head -n 4096 $VOLUME_CONTAINER | sha1sum | cut -f 1 -d " ")
        echo -e "\ndev-random generated random SHA1 hash $randomstring from host"
        ;;
    sha256)
        randomstring=$(head -n 4096 $VOLUME_CONTAINER | sha256sum | cut -f 1 -d " ")
        echo -e "\ndev-random generated random SHA256 hash $randomstring from host"
        ;;
    *)
        echo "Validation error: expected --hash=[sha256, sha1, or md5]"
        exit 1
        ;;
    esac

    # Build a JSON string. The JSON data may have spaces, newlines, etc.
    JSON_STRING=$(jq -n -r --arg hs "$randomstring" '{"random hash": $hs}')
    echo $JSON_STRING

    # Can't simply use -d $JSON_STRING, as this has newlines, spaces.
    # Instead, pipe it into the command.
    echo "POST to http://$ENDPOINT:$PORT"
    # POST this to the target
    echo $JSON_STRING | curl -d @- -H "Content-Type: application/json" -X POST http://$ENDPOINT:$PORT || echo "Curl exited with status $?"

    sleep $interval
done
