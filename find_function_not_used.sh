#!/bin/bash
#
# >>> Copyright
#
# Leonardo Rossi <leonardo.r@cern.h>
#
# Copyright (C) 2015 CERN.
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
# >>> About
#
# Generate a png where you can see function dependencies.
# The graph explain who use the function inside a file/directory.
#
# >>> Usage
#
#  $> cd /src/invenio
#  $> /path/to/find_function_not_used.sh function_source where_look
#
#  e.g. /path/to/find_function_not_used.sh invenio/modules/access/control.py invenio/
#
#       It generate a list "[count] [function] where [count] is how much time
#       the expression "myfunction(" is found in the code.
#
#       Note: the [count] value == 1 means that the function is only defined
#             but never used.
#
#       Note: to exclude function_source from the count:
#
#       /path/to/find_function_not_used.sh function_source where_look no
#
#
# >>> Install
#
#  note: you need to install GraphViz
#

# check arguments
if [ "$#" -lt 2 ]; then
  echo "usage $0 FUNCTION_SOURCE WHERE_LOOK"
  exit 1
fi

usage_graph(){
  FUNCTION_SOURCE=$1
  WHERE_LOOK=$2
  NO_COUNT_SOURCE=$3
  function_list=`git grep "def \w*(" $FUNCTION_SOURCE | awk -F":" '{print $2}' | awk '{print $2}' | awk -F"(" '{print $1}' | sort -u`
  for fun in $function_list; do
    if [ -z "$NO_COUNT_SOURCE" ]; then
       USAGE_COUNT=`git grep "$fun(" | wc -l`
    else
       USAGE_COUNT=`git grep "$fun(" -- "$WHERE_LOOK" ":!$FUNCTION_SOURCE" | wc -l`
    fi
    echo -e "$USAGE_COUNT\t$fun"
  done
}

# generate list "[count] [function_name]"
usage_graph $1 $2 $3
