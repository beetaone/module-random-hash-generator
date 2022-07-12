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

# Check volume mounts
if [ ! -c "$VOLUME_CONTAINER" ]; then
    echo "Entrypoint validation error: Expected a character special file object at $VOLUME_CONTAINER"
    exit 1
fi

# Help message
function usage {
    cat <<HELP_USAGE
    usage: $0 --interval <s> --hash <hash method>
        -i|--interval in seconds
        -s|--hash method
        -h|--help Display this message
HELP_USAGE
}

#####################
# Parameter parsing #
#####################
OPTIONS=i:s:h # Colon expects a parameter
LONGOPTS=interval:,hash:,help

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 2
fi

eval set -- "$PARSED"

# Defaults
interval=10
hash=sha256
while true; do
    case "$1" in
    -i | --interval)
        interval=$2
        if ! [[ "$interval" =~ ^[0-9]+$ ]]; then
            echo "ERROR Set interval to integer seconds"
            exit 1
        fi
        shift 2
        ;;
    -s | --hash)
        hash=$2
        shift 2
        ;;
    -h | --help)
        usage
        shift 1
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Programming error"
        exit 3
        ;;
    esac
done

echo "Hash=$hash"
echo "Interval=$interval"

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
case $hash in
md5) ;;

sha1) ;;

sha256) ;;

*)
    echo "Entrypoint validation error: expected --hash=[sha256, sha1, or md5]"
    exit 1
    ;;
esac

source ./main.sh
