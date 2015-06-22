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
#  $> /path/to/function_usage.sh function_source where_look deps.png
#
#  e.g. /path/to/function_usage.sh invenio/modules/access/control.py invenio/ deps.png
#
#       It generate a graph where you can graphically identify where the
#       functions inside invenio/modules/access/control.py are called
#
# >>> Install
#
#  note: you need to install GraphViz
#

# check arguments
if [ "$#" -lt 2 ]; then
  echo "usage $0 FUNCTION_SOURCE WHERE_LOOK [OUTPUT_FILE]"
  exit 1
fi

usage_graph(){
  FUNCTION_SOURCE=$1
  WHERE_LOOK=$2
  function_list=`git grep "def \w*(" $FUNCTION_SOURCE | awk -F":" '{print $2}' | awk '{print $2}' | awk -F"(" '{print $1}' | sort -u`
  echo "digraph {"
  for fun in $function_list; do
     USAGE_LIST=`git grep $fun | grep -v "$FUNCTION_SOURCE" | awk -F":" '{print$1}' | sort -u`
     for orig in $USAGE_LIST; do
       echo -e "\t\"$orig\" -> \"$fun\";"
     done
  done
  echo "}"
}

# get output file name
OUTPUT_FILE=${3}
if [ -z "$OUTPUT_FILE" ]; then
  # use a temporary file
  OUTPUT_FILE=`mktemp --suffix=".png"`
fi
# create a temporary file for digraph
TMPFILE=`mktemp`
# generate dependency graph
usage_graph $1 $2 > $TMPFILE
# generate image
dot -Tpng $TMPFILE -o $OUTPUT_FILE
#
echo "output file: $OUTPUT_FILE"
