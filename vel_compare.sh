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

echo "msisdn;Date;Duration;A_NUMBER;B_NUMBER;REDIR_NUMBER;REDIR_IMSI;TYPE;CHECK;IsA-Number;TestCaseID;Duration"

# Читаем наши данные построчно со второй строки
not1=0
while read line
do
  if [ $not1 -eq 0 ] ; then not1=1; continue ; fi

  wrongA="OK"

  ANum=`echo $line | cut -s -d ';' -f 4`
  BNum=`echo $line | cut -s -d ';' -f 1`
#  CTime=`echo $line | cut -s -d ';' -f 3 | cut -s -d ' ' -f 2 | cut -s -d ':' -f 1-2`
  CTime=`echo $line | cut -s -d ';' -f 2 | cut -s -d ':' -f 1 | sed -e 's/2017/17/'`
  DTime=`echo $line | cut -s -d ';' -f 3`
  RStr=$(cat $file2 | grep $BNum | grep $ANum ) # | grep $CTime )

# Запись не найдена у оператора
  if [ $? -ne 0 ]
  then
    RStr=$(cat $file2 | grep $BNum | grep "$CTime" )
    if [ $? -ne 0 ]
    then
      echo "$line;NOT FOUND;NOT FOUND;;$DTime"
      continue
    else
      OStr=$(echo "$RStr" | cut -s -d ';' -f 7)
      if [ -n "$OStr" ]
      then
        RES="Rejected"
        wrongA="NONE"
        TestID=${RStr:0:$[`expr index "$RStr" ";"`-1]}
        for i in 1 2 3 4 6 14 15 17 18   # OK1 & OK2
        do
          echo "$OStr" | grep -qi "${RString[$i]}"
          if [ $? -eq 0 ]
            then
              RES=${RCode[$i]}
              wrongA="WRONG A-NUMBER"
              TestID=${RStr:0:$[`expr index "$RStr" ";"`-1]}
#              (>&2 echo "$TestID")
              break
          fi
        done
      else
        RES="OK1"
        wrongA="WRONG A-NUMBER"
        TestID=${RStr:0:$[`expr index "$RStr" ";"`-1]}
#        (>&2 echo "$TestID")
      fi
      echo "$line;$RES;$wrongA;$TestID;$DTime"
      continue
    fi
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
        TestID=${RStr:0:$[`expr index "$RStr" ";"`-1]}
        break
      fi
    done
  else
    RES="OK1" 
    TestID=${RStr:0:$[`expr index "$RStr" ";"`-1]}
  fi
  echo "$line;$RES;$wrongA;$TestID;$DTime"
done < $file1
