#!/bin/sh

USAGE="Usage: ./startup.sh [path/to/bin/dir] binary_name"

PATH_BIN="/usr/local/bin"
BINARY=""

if [ "$EUID" -ne 0 ];
then
    echo "Please run the script as root"
    exit 1
fi


if [ "$#" -eq 2 ];
then
    if [ ! -d "$1" ];
    then
        echo "Destination: $1 does not exist, please try again!"
        exit 1
    fi
    PATH_BIN="$1"
elif [ "$#" -gt 2 ];
then
    echo "Too many arguments\n$USAGE"
    exit 1
fi

if [ -d "$2" ];
then
    BINARY="$2"
else
    echo "Binary name not found, please try again!"
    exit 1
fi

echo "Using $PATH_BIN as directory of destination"

cp "$BINARY/$BINARY.sh" "$PATH_BIN/"


