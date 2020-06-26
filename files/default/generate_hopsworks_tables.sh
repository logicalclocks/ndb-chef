#!/bin/bash

if [ "$1" == "-h" ] ; then
    echo "Usage: $0 [path/to/x.y__initial_tables.sql]"
    exit 2
fi

if [ "$#" -eq 1 ] ; then
    schema=$1
else
    schema="../../..//hopsworks-chef/files/default/sql/ddl/1.3.0__initial_tables.sql"
fi

version=$(basename $schema | sed -e 's/__.*//')

if [ ! -e  ] ; then
    echo "Could not find x.y__initial_tables.sql at path $schema"
    echo "Re-run command with path to x.y__initial_tables.sql file:"
    echo "$0 /path/to/x.y__initial_tables.sql"
    exit 2
fi

#   | tr ' \n' ' ')
hopsworks_tables_one=$(grep -i table $schema | grep -i "^CREATE TABLE \`" | awk '{ print $3 }' | sed -e 's/`//g' )
hopsworks_tables_two=$(grep -i table $schema | grep -i "^CREATE TABLE IF NOT EXISTS \`" | awk '{ print $6 }' | sed -e 's/`//g' )

txt="hopsworks_tables-${version}.txt"
echo "$hopsworks_tables_one" > $txt
echo "$hopsworks_tables_two" >> $txt
#perl -pi -e 's/\n/ /g' $txt

echo "Export complete."
echo "The list of hopsworks_tables is now in the files:"
echo "$txt"
echo ""
