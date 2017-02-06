#!/bin/sh

# $1 - наши данные csv
# $2 - данные ОПСОСа

# Коды для errorText
RCode = (
SYSERR
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
LOST
)

RString = (
"Response code 603"
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
"unknown result array 'RTP_SendAudio'"
)

