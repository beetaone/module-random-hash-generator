#!/bin/sh
# Build a JSON string. The JSON data may have spaces, newlines, etc.
JSON_STRING=$( jq -n -r --arg hs "$randomstring" '{"random hash": $hs}' )
echo $JSON_STRING

# Can't simply use -d $JSON_STRING, as this has newlines, spaces.
# Instead, pipe it into the command.
echo "POST to http://$ENDPOINT:$PORT"
# POST this to the target
echo $JSON_STRING | curl -d @- -H "Content-Type: application/json" -X POST http://$ENDPOINT:$PORT