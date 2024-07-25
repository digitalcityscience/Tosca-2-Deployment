#!/bin/sh

# Check if TOSCA-2 directory exists, if not clone from GitHub
if [ ! -d "./TOSCA-2" ]; then
    echo "Cloning TOSCA-2 from GitHub"
    apk add --no-cache git
    git clone https://github.com/digitalcityscience/TOSCA-2.git ./TOSCA-2
else
    echo "TOSCA-2 directory exists locally"
fi
