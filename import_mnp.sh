#!/bin/sh -x

server=127.0.0.1
user=test
filename=mnp
rpath="/tmp/"
lpath="/tmp/local/"

date=`date +%d-%m-%Y`

ssh $user@$server mv $rpath$filename.csv $rpath$filename_$date.csv
if [ $? -eq 0 ]
then 
  scp $user@$server:$rpath$filename_$date.csv $lpath
  if [ $? -eq 0 ]
    then
      ssh $user@$server rm -f $rpath$filename_$date.csv
    else
      logger -t mnp "Cant download file "$filename_$date.csv
  fi
else logger -t mnp "Cant access source file"
fi
