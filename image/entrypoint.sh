#!/bin/bash
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?, but I don’t do that.
set -o errexit -o pipefail -o noclobber -o nounset

echo "Entrypoint script"
echo "$@"

# Check volume mounts
if [ ! -c $VOLUME_CONTAINER ]
then
    echo "Entrypoint validation error: Expected a character special file object at $VOLUME_CONTAINER"
    exit 1
fi

# Help message
function usage {
    cat <<HELP_USAGE
    usage: $0 --interval <ms> --hash <hash method>
        -i|--interval
        -s|--hash
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
interval=3000
hash=sha256
while true; do
    case "$1" in
        -i|--interval)
            interval=$2
            if ! [[ "$interval" =~ ^[0-9]+$ ]]
            then
                echo "ERROR Set interval to integer milliseconds"
                exit 1
            fi
            shift 2
            ;;
        -s|--hash)
            hash=$2
            shift 2
            ;;
        -h|--help)
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

echo $interval, $hash

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
case $hash in
    md5)
        # Get 4096 bytes of random data. Take the hash. Do not keep the dash after the string. Assign to variable.
        randomstring=$(head -n 4096 $VOLUME_CONTAINER | md51sum | cut -f 1 -d " ")
        echo "Generated random SHA1 hash $randomstring from host"
    ;;
    sha1)
        randomstring=$(head -n 4096 $VOLUME_CONTAINER | sha1sum | cut -f 1 -d " ")
        echo "Generated random SHA1 hash $randomstring from host"
    ;;
    sha256)
        randomstring=$(head -n 4096 $VOLUME_CONTAINER | sha256sum | cut -f 1 -d " ")
        echo "Generated random SHA256 hash $randomstring from host"
    ;;
    *)
        echo "Entrypoint validation error: expected --hash=[sha256, sha1, or md5]"
        exit 1
esac

source ./main.sh
