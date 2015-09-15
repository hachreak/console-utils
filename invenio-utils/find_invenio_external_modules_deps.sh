#!/bin/bash
#
# >>> About
#
# Generate a png of modules dependencies on invenio
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
#  $> cd /src/
#  $> /path/to/find_invenio_external_modules_deps.sh deps.png
#  $> /path/to/invenio_internal_dependencies.sh deps.png
#
#  note: you need to install GraphViz.
#        in src/ directory we have all the modules (as git repositories).

# find home
HOME=`pwd`

find_deps(){
  git grep -P "^( +)from invenio" -- '*.py' | grep -v ^tests | grep -v ^docs | awk -F: '{print $2}' | sed -e 's/^[ \t]*//' | awk '{print $2}' | awk -F"." '{print $1}' | sort -u
}

get_src_pkg_name(){
  git grep -P "^( +)from invenio" -- '*.py' | grep -v ^tests | grep -v ^docs | awk -F"/" '{print $1}' | head -n1
}

print_digraph(){
  echo "digraph {"
  for i in `ls -1d */`; do
    cd $HOME/$i
    if [ -d .git ]; then
      SRC=`get_src_pkg_name`
      DEPS=`find_deps`
      if [ -n "$DEPS" ]; then
        for j in $DEPS; do
          if [ "$SRC" != "$j" ]; then
            echo -e "\t$SRC -> $j"
          fi
        done
      fi
    fi
    cd $HOME
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
print_digraph > $TMPFILE
# generate image
dot -Tpng $TMPFILE -o $OUTPUT_FILE
#
echo "tmp digraph: $TMPFILE"
echo "output file: $OUTPUT_FILE"
