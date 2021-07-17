#!/bin/sh
echo "Entrypoint script"

# Assert number of args
if [ ! $# -eq 1 ]
  then
    echo "Expected 1 argument, either [sha256, sha1, or md5]"
    exit 1
fi


# Check volume mounts
# if [ ! -f /mounted ]
# then
#     echo "Entrypoint validation error: Expected a file-like object at /mounted"
#     exit 1
# fi

# Assert hash functions exist as executables
if ! [ -x "$(command -v md5sum)" ]
then
    echo "md5sum could not be found"
    exit
fi
if ! [ -x "$(command -v sha1sum)" ]
then
    echo "sha1sum could not be found"
    exit
fi
if ! [ -x "$(command -v sha256sum)" ]
then
    echo "sha256sum could not be found"
    exit
fi

# Assert parameter matches
case $1 in
    md5)
        # Get 4096 bytes of random data. Take the hash. Do not keep the dash after the string. Assign to variable.
        randomstring=$(head -n 4096 /mounted | md51sum | cut -f 1 -d " ")
        echo "Generated random SHA1 hash $randomstring from host"
    ;;
    sha1)
        randomstring=$(head -n 4096 /mounted | sha1sum | cut -f 1 -d " ")
        echo "Generated random SHA1 hash $randomstring from host"
    ;;
    sha256)
        randomstring=$(head -n 4096 /mounted | sha256sum | cut -f 1 -d " ")
        echo "Generated random SHA256 hash $randomstring from host"
    ;;
    *)
        echo "Entrypoint validation error: expected [sha256, sha1, or md5]"
        exit 1
esac

# randomstring=$(head -n 4096 /mounted | sha256sum | cut -f 1 -d " ")

# Build a JSON string. The JSON data may have spaces, newlines, etc.
JSON_STRING=$( jq -n -r --arg hs "$randomstring" '{"random hash": $hs}' )
echo $JSON_STRING

# Can't simply use -d $JSON_STRING, as this has newlines, spaces.
# Instead, pipe it into the command.
echo "POST to http://$ENDPOINT:$PORT"
echo $JSON_STRING | curl -d @- -H "Content-Type: application/json" -X POST http://$ENDPOINT:$PORT