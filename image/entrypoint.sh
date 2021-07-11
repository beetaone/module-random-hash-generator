#!/bin/sh
echo "Entrypoint script"
echo $# Args: $@
echo "Environment:"
env

curl -d '{"key1":"value1", "key2":"value2"}' -H "Content-Type: application/json" -X POST http://localhost:$PORT