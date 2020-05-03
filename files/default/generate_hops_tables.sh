#!/bin/bash

if [ "$1" == "-h" ] ; then
    echo "Usage: $0 [path/to/schema.sql] [version]"
    exit 2
fi

if [ "$#" -gt 0 ] ; then
    schema=$1
else
    schema="../../../hops-metadata-dal-impl-ndb/schema/schema.sql"
fi

if [ "$#" -gt 1 ] ; then
    VERSION=$2
else    
    VERSION=`grep -o -a -m 1 -h -r "version>.*</version" ../../../hops-metadata-dal-impl-ndb/pom.xml | head -1 | sed "s/version//g" | sed "s/>//" | sed "s/<\///g"`
fi    


if [ ! -e  ] ; then
    echo "Could not find schema.sql at path $schema"
    echo "Re-run command with path to schema.sql file:"
    echo "$0 /path/to/schema.sql"
    exit 2
fi

# | tr ' \n' ' ')
hdfs_tables=$(grep -i table $schema | awk '{ print $3 }' | sed -e 's/`//g' | grep hdfs_ )
yarn_tables=$(grep -i table $schema | awk '{ print $3 }' | sed -e 's/`//g' | grep yarn_ )

txt=hops-tables-${VERSION}.txt
echo "$hdfs_tables" > $txt
echo "$yarn_tables" >> $txt
#perl -pi -e 's/\n/ /g' $txt

echo "Export complete."
echo "The list of hdfs_tables and yarn_tables are now in the files:"
echo "$txt" 
echo ""
