#!/bin/sh

set -eu

# $1 New version number
# $2 File location

perl -pi -e "s/(?<=roktsdk:)(.*)(?='\))/$1/g" $2