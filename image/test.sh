#!/bin/bash
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?, but I don’t do that.
set -o errexit -o pipefail -o noclobber -o nounset

usage="$(basename "$0") [-h] [-s n] -- program to calculate the answer to life, the universe and everything

where:
    -h  show this help text
    -s  set the seed value (default: 42)"

OPTIONS=i:s:
LONGOPTS=interval:,hash:

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
            # echo "Interval $2"
            # echo "OK Interval"
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