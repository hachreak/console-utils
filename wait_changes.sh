#!/bin/bash
#
# >>> About
#
# This helper execute a command PROGRAM $ARGS each time the FILE
# changes,
#
# Tested on:
# Ubuntu 14.04 LTS (Trusty Tahr) amd64
#
# >>> Copyright
#
# Leonardo Rossi <leonardo.r@cern.h>
#
# Copyright (C) 2014 CERN.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.
#
# >>> Usage
#
# laptop>  wait_changes.sh /path/to/file PROGRAM ARGS
#
# When $FILE changed, execute another time the program passed by arguments

# params
FILE=$1
PROGRAM=$2
shift
shift
ARGS=$@

# colors
red='\e[0;31m'
green='\e[0;32m'
blue='\e[0;34m'
NC='\e[0m' # No Color

while true; do
    change=$(inotifywait -e close_write,moved_to,create $FILE)
    echo -e "${blue}[Execute again]${NC} $PROGRAM $ARGS"
    $PROGRAM $ARGS
done
