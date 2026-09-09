#!/bin/sh

USAGE="Usage: ./setup.sh (-d path/to/bin/dir) (-b binary_name...) -b binary_name"

PATH_BIN="/usr/local/bin"
BINARY=""

if [ "$EUID" -ne 0 ];
then
    echo "Please run the script as root"
    exit 1
fi

while [ "$#" -gt 0 ];
do
    case "$1" in
        -d)
            shift
            [ "$#" -eq 0 ] && echo "Bad argument, $USAGE" && exit 1

            [ ! -d "$1" ] && echo "Destination: $1 does not exist, please try again!" && exit 1

            PATH_BIN="$1"
            shift

            ;;
        -b)
            shift
            [ "$#" -eq 0 ] && echo "Bad argument, $USAGE" && exit 1

            [ ! -d "$1" ] && echo "Binary name not found, please try again!" && exit 1

            BINARY="$BINARY $1"
            shift
            ;;
        *)
            echo "Bad argument, $USAGE"
            exit 1
            ;;
    esac
done

[ -z "$BINARY" ] && echo -e "Not enough argument\n$USAGE" && exit 1

echo "Using $PATH_BIN as directory of destination"

for bin in $BINARY;
do
    echo "$bin"
    cp "$bin/$bin.sh" "$PATH_BIN/"
    chmod 711 "$PATH_BIN/$bin.sh"
done

exit 0


