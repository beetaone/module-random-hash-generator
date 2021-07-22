#!/bin/bash
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?, but I don’t do that.
set -o errexit -o pipefail -o noclobber -o nounset


function usage {
    cat <<HELP_USAGE
    usage: $0 --interval <ms> --hash <hash method>
        -i|--interval
        -s|--hash
        -h|--help Display this message
HELP_USAGE
}

OPTIONS=i:s:h
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
            # echo "Hash $2"
            # echo "OK hash"
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