#!/bin/sh

base_p="/tmp/ftproot"

cd $base_p
mv pif/pif.csv bak/$(date +"%Y%m%d")-pif.csv

touch pif/pif.csv

for i in  $( ls */*.csv | grep -v pif | grep -v bak )
do
  echo $i
  tail -n +2 $i >> pif/pif.csv
  dir=$( echo $i | cut -d "/" -f 1 )
  name=$( echo $i | cut -d "/" -f 2 )
  echo mv $i $dir/bak/$(date +"%Y%m%d")-$name
done

