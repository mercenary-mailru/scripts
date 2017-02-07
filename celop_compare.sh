#!/bin/sh

# $1 - наши данные csv
# $2 - данные ОПСОСа

if [ ! $# == 2 ]; then
  echo "Usage: $0 \"TCG data\" \"COp data\""
  exit 1
fi

if [ ! -f $1 ]; then 
  echo "File $1 does not exist"
  exit 1
fi

if [ ! -f $2 ]; then
  echo "File $2 does not exist"
  exit 1
fi

file1=$1
file2=$2

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

echo "TYPE;;Date;A_NUMBER;B_NUMBER;Duration;REDIR_NUMBER;REDIR_IMSI;msisdn;HOUR;CHECK;TestCaseID"

# Читаем наши данные построчно со второй строки
not1=0
while read line
do
  if [ $not1 -eq 0 ] ; then not1=1; continue ; fi
  ANum=`echo $line | cut -s -d ';' -f 4`
  BNum=`echo $line | cut -s -d ';' -f 9`
  CTime=`echo $line | cut -s -d ';' -f 3 | cut -s -d ' ' -f 2 | cut -s -d ':' -f 1-2`
  RStr=$(cat $file2 | grep $ANum | grep $BNum ) # | grep $CTime )

# Запись не найдена у оператора
  if [ $? -ne 0 ]
  then
    echo "$line;NOT FOUND;;"
    continue
  fi

  OStr=$(echo "$RStr" | cut -s -d ';' -f 7)
  if [ -n "$OStr" ]                           # -a "$OStr" != " " ]
  then
    RES="UNKNOWN RESPONCE"
    TestID=";"
    for i in `seq 0 $COUNT`
    do
      echo "$OStr" | grep -qi "${RString[$i]}"
      if [ $? -eq 0 ]
      then
        RES=${RCode[$i]}
        TestID=${RStr:0:`expr index "$RStr" ";"`}
        break
      fi
    done
  else
    RES="OK1" 
    TestID=${RStr:0:`expr index "$RStr" ";"`}
  fi
  echo "$line;$RES;$TestID"
done < $file1
