#!/bin/bash

set -eu

# $1 New version number
# $2 File location

perl -pi -e "s/(?<=\"Rokt-Widget\", \"~> )(.*)(?=\")/$1/g" $2