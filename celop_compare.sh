#!/bin/sh

# $1 - наши данные csv
# $2 - данные ОПСОСа
file1=/tmp/1.csv
file2=/tmp/2.csv
file3=/tmp/3.csv

# Коды для errorText
RCode=( SYSERR 
OK2 
OK2
OK2
OK2
LOST
OK2
LOST
LOST
LOST
SYSERR
LOST
SYSERR
LOST
OK2
OK1
LOST
OK1
OK2
LOST )

RString=( "Response code 603"
"connect received for unanswered call. Pre-charging detected"
"got CONNECT_IND"
"got DISCONNECT_B3_IND"
"got NO CARRIER"
"got unexpected connect indication. False answer detected"
"has been disconnected by P-CSCF"
"no call received"
"No more retries for INVITE since there was already a response"
"received disconnect from remote side"
"received response code: 500"
"Response code 486"
"Service Unavailable with reason"
"SIP 404 Not Found"
"SyncRequest Synchronization error, probably due to error"
"timeout reached, aborted after maximum job duration of"
"unexpected response, got DISCONNECT_IND"
"VQ_Analyse_P863"
"unknown result array 'RecordAudioStop'"
"unknown result array 'RTP_SendAudio'" )

COUNT=$((${#RString[@]}-1))
# echo "$string" | grep -i "$substring" >/dev/null; then

# Читаем наши данные построчно
while read line
do
  ANum=`echo $line | cut -s -d ';' -f 4`
  BNum=`echo $line | cut -s -d ';' -f 9`
  CTime=`echo $line | cut -s -d ';' -f 3 | cut -s -d ' ' -f 2 | cut -s -d ':' -f 1-2`
  OStr=$(cat $file2 | grep $ANum | grep $BNum | grep $CTime | cut -s -d ';' -f 7)
#  echo $ANum ";" $BNum ";" $CTime ";" $OStr ";"
  RES=""
  if [ -n "$OStr" ]
# -a "$OStr" != " " ]
  then
    RES="NOT FOUND"
    for i in `seq 0 $COUNT`
      do
#        echo "$OStr" ${RString[$i]}
        echo "$OStr" | grep -qi "${RString[$i]}"
        if [ $? -eq 0 ]
        then
          RES=${RCode[$i]}
        fi
      done
  else
    R="OK"
  fi
  echo $ANum ";" $BNum ";" $CTime ";" $OStr ";" $RES
done < $file1
