#!/bin/bash
#
# >>> About
#
# Generate a png of internal dependencies on invenio
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
# >>> Usage
#
#  $> cd /src/invenio
#  $> /path/to/invenio-dependencies.sh deps.png
#
#  note: you need to install GraphViz

# print a list of dependencies
list_dep(){
  MODULE=$1
  # external dependencies
  # L3=`git grep "^import" $MODULE/|awk '{print $2}'|sort -u`
  # L2=`git grep "from.*import" $MODULE/|awk -F":" '{print $2}'| sed -e 's/^[ \t]*//'|awk '{print $2}'|grep -v "^\."|awk -F"." '{print $1}'|grep -v __future__|grep -v ^invenio|grep -v ^from|sort -u`
  # internal dependencies
  L1=`git grep "from.*import" $MODULE/|awk -F":" '{print $2}'| sed -e 's/^[ \t]*//'|awk '{print $2}'|grep -v "^\."|grep ^invenio|sort -u`

  # use only internal dependencies
  for i in `echo $L1`; do echo $i; done|sort -u
}

# print digraph for GraphViz
print_all_digraph(){
  echo "digraph {"
  # for each invenio module
  for i in `ls invenio/modules/*/ -d -1`; do
    # convert directory to python module
    mod_src=`echo ${i::-1}|sed 's/\//\./g'`
    # get list of dependencies
    DEP=`list_dep $i`
    # for each dependency
    for j in `echo $DEP`; do
      # print only modules dependencies
      if [ -n "`echo $j|grep modules`" ]; then
        mod_dest=`echo $j|awk -F"." '{print $1"."$2"."$3}'`
        if [ "$mod_src" != "$mod_dest" ]; then
          echo -n "." 1>&2
          echo -e "\t\"$mod_src\" -> \"$mod_dest\";"
        fi
      fi
    done
  done
  echo "}"
}

# get output file name
OUTPUT_FILE=${1}
if [ -z "$OUTPUT_FILE" ]; then
  # use a temporary file
  OUTPUT_FILE=`mktemp`
fi
# create a temporary file for digraph
TMPFILE=`mktemp`
print_all_digraph > $TMPFILE
# generate image
dot -Tpng $TMPFILE -o $OUTPUT_FILE
#
echo "output file: $OUTPUT_FILE"
