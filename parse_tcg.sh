#!/bin/sh
#
# Парсинг данных от генератора с добавлением 3х колонок
#

if [ ! $# == 1 ]; then
  echo "Usage: $0 \"TCG data\""
  exit 1
fi

if [ ! -f $2 ]; then
  echo "File $1 does not exist"
  exit 1
fi

# Коды для errorText
RCode=( RESULT
SYSERR
OK1
OK1
OK2
OK2
OK2
OK2
OK2
OK2
OK2
OK2
LOST
LOST
LOST
LOST
LOST
LOST
LOST
LOST
LOST
REJECTED
REJECTED
REJECTED
REJECTED
REJECTED
SYSERR
SYSERR
SYSERR )

# Сообщения об ошибках 
RString=( "errText_substring"
"invalid CGREG reply received"
"timeout reached, aborted after maximum job duration of 10:00"
"VQ_Analyse_P863"
"got NO CARRIER"
"SyncRequest Synchronization error, probably due to error"
"unknown result array 'RecordAudioStop'"
"has been disconnected by P-CSCF"
"connect received for unanswered call. Pre-charging detected"
"got DISCONNECT_B3_IND"
"got CONNECT_IND"
"No CLI received"
"received disconnect from remote side"
"No more retries for INVITE since there was already a response"
"no call received"
"got unexpected connect indication. False answer detected"
"unknown result array 'RTP_SendAudio'"
"SIP 404 Not Found"
"unexpected response, got DISCONNECT_IND"
"Response code 486"
"Response code 404"
"Service Unavailable with reason"
"Response code 603"
"received response code: 500"
"Response code 403"
"Response code 504"
"LocationUpdate Invalid mobile behavior"
"Interface lost"
"SIM Emulation Error" )

COUNT=$((${#RString[@]}-1))

in_file=$1
out_file=${in_file:0:$((${#in_file}-4))}_parsed.csv

# Читаем наши данные построчно со второй строки
not1=0
while read line
do
  if [ $not1 -eq 0 ] ; then not1=1; echo "$line;RESULT;DAY_HOUR;DAY;" > "$out_file" ; continue ; fi

  ErrStr=`echo $line | cut -s -d ";" -f7`
  Date=`echo $line | cut -s -d ";" -f3`

  Day=${Date:0:2}
  Time=${Date/* /}
  Hour=${Time:0: -3}

#continue

  RES="OK1"
  if [ -n "$ErrStr" ]
  then
    for i in `seq 0 $COUNT`
    do
#      echo "$ErrStr" | grep -qi "${RString[$i]}"
#      if [ $? -eq 0 ]
      if [[ "$ErrStr" =~ "${RString[$i]}" ]]
      then
        RES=${RCode[$i]}
        break
      fi
    done
  fi

  echo "$line;$RES;$Day-$Hour;$Day;" >> "$out_file"

done < $in_file
