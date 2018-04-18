#!/bin/sh

for i in 3 4 5 6 7
  do
    echo $i
    cat $1 | while read line; do echo ${line:1:$i}; done > 1.txt && cat 1.txt | sort -u > numbers_$i.csv
  done
