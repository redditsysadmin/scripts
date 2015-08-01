#! /bin/bash

SERVER=google.com  #SERVER TO PING - WILL BE OVERWRITTEN IF PROVIDED BY ARGUMENT
RATE=5 #RATE TO CHECK THE SERVER (IN MINUTES) - WILL BE OVERWRITTEN IF PROVIDED BY ARGUMENT
SID= #ACCOUNT SID
AUTH_TOKEN= #AUTH TOKEN
NUMBER= #NUMBER REGISTERED WITH TWILIO
RECIPIENT= #SMS RECIPIENT - WILL BE OVERWRITTEN IF PROVIDED BY ARGUMENT

while getopts s:r:t: opt; do
  case $opt in
  s)
      SERVER=$OPTARG
      ;;
  r)
      RATE=$OPTARG
      ;;
  t)
      RECIPIENT=$OPTARG
      ;;
  esac
done

while true
do
  if ping -c 1 $SERVER > /dev/null;
    then echo "Everything is OK at $(date)"
  else
    if [ "x${RECIPIENT}" != "x" ]
    then
      echo "Server could not be reached at $(date)" | ./twilio-sms.sh -d $NUMBER -u $SID -p $AUTH_TOKEN $RECIPIENT
    else
      echo "Server could not be reached at $(date), but no phone number was entered"
    fi
    exit 0
  fi
  sleep ${RATE}m
done
