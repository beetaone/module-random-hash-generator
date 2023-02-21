#!/bin/bash
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?, but I don’t do that.
set -o errexit -o pipefail -o noclobber -o nounset

echo "[ENTRYPOINT] Entrypoint script for the module."

: "${MODULE_NAME:?Need to set MODULE_NAME environment variable to string}"
: "${MODULE_TYPE:?Need to set MODULE_TYPE environment variable to string (Input, Processing, Output)}"

# Validate the environment according to module type
if [[ "$MODULE_TYPE" == "Input" ]]
then
    : "${EGRESS_URLS:?Need to set EGRESS_URLS environment variable to string}"
elif [[ "$MODULE_TYPE" == "Processing" ]]
then
    : "${INGRESS_HOST:?Need to set INGRESS_HOST environment variable to string}"
    : "${INGRESS_PORT:?Need to set INGRESS_PORT environment variable to string}"
    : "${EGRESS_URLS:?Need to set EGRESS_URLS environment variable to string}"
elif [[ "$MODULE_TYPE" == "Output" ]]
then
    : "${INGRESS_HOST:?Need to set INGRESS_HOST environment variable to string}"
    : "${INGRESS_PORT:?Need to set INGRESS_PORT environment variable to string}"
else
    echo "Unrecognized MODULE_TYPE = $MODULE_TYPE, choose from Input, Processing, Output"
    exit 1
fi
echo "[ENTRYPOINT] Environment validated."

# Defaults
if [ -z "$INTERVAL" ]; then
    INTERVAL=10
fi
if [ -z "$HASH" ]; then
    HASH=sha256
fi
if [ -z "$LABEL" ]; then
    LABEL="hash"
fi

echo "Hash=$HASH"
echo "Interval=$INTERVAL"

# Assert hash functions exist as executables
if ! [ -x "$(command -v md5sum)" ]; then
    echo "md5sum could not be found"
    exit
fi
if ! [ -x "$(command -v sha1sum)" ]; then
    echo "sha1sum could not be found"
    exit
fi
if ! [ -x "$(command -v sha256sum)" ]; then
    echo "sha256sum could not be found"
    exit
fi

# Assert parameter matches
case $HASH in
md5) ;;

sha1) ;;

sha256) ;;

*)
    echo "Entrypoint validation error: expected HASH=[sha256, sha1, or md5]"
    exit 1
    ;;
esac

source ./main.sh
