#!/bin/bash
#
# Проверка наличия записей о вызовах в данных от операторов
#

DD=`date "+%d" -d yesterday`
#DD=10
MM=`date "+%m" -d yesterday`
YY=`date "+%Y" -d yesterday`

TMPCSV=/tmp/agw_$YY.$MM.$DD.csv
RESCSV="/ftproot/btc_cdr/fraud/fraud_"$YY.$MM.$DD"_A1gw_"
INPCSV=/ftproot/tcg/A1_4cmp/Report_13475_All_$(date "+%Y%m%d")*
#INPCSV=/ftproot/tcg/Report9855_$YY$MM$(($DD+1))*

rm -f $TMPCSV
rm -f /tmp/fraud-$YY.$MM.$DD.csv
rm -f $RESCSV

cat /ftproot/btc_cdr/axe/i170002_$YY$MM$DD* >> $TMPCSV
cat /ftproot/btc_cdr/ewsd/AMA.$YY-$MM-$DD* >> $TMPCSV
#cat /ftproot/cdr/$DD.$MM.$YY* | sed -e "s/;user/,user/" | cut -d ";" -f 18-26 -s >> $TMPCSV
cat /ftproot/mvts_tcg/$YY.$MM.$DD* >> $TMPCSV

for I in $INPCSV
do
	RSC=(` echo $I | cut -d "_" -f 7-8` )

install -m 644 /dev/null "$RESCSV$RSC"
echo "Timestamp;Operator A;A1-number;Operator B;B-number;" > $RESCSV$RSC

A1s=( `tail -n+2 $I | sed -e 's/;;/;88888888;/' | cut -d "," -f 4 -s | tr -d '+'` )
Bs=( `tail -n+2 $I | cut -d "," -f 5 -s | sed -e 's/^3*75//' | sed -e "s/E0.//"` )
readarray TIME <<< "$( tail -n+2 $I | cut -d "," -f 2 -s )"

COUNT=$((${#A1s[@]}-1))
FRODS=0

for i in `seq 0 $COUNT`
#for i in `seq 0 99`
do
  if [ -t 1 ] ; then printf "%20s\r" "$i / ${#A1s[@]} / $FRODS"	; fi
  if [ "${A1s[$i]}" != "88888888" ]
    then
      grep ${A1s[$i]} $TMPCSV | grep ${Bs[$i]} 2>&1 > /dev/null
      if [ $? -eq 1 ]
      then
        case ${A1s[$i]} in
          37533*|37529[2578]* )   AOP="МТС";;
  		    37544*|37529[13469]* )  AOP="Velcom";;
  			  37525* )                AOP="Life";;
          790[0248]*|795[123]* )  AOP="TELE2";;
          797* )                  AOP="TELE2";;
          790[3569]*|796* )       AOP="BeeLine";;
          791* )                  AOP="MTC-RU";;
          792* )                  AOP="Мегафон";;
  				375[0123456789]* )      AOP="Белтелеком";;
          * )                     AOP="";;
  			esac
        case ${Bs[$i]} in
          33*|29[2578]* )   BOP="МТС";;
          44*|29[13469]* )  BOP="Velcom";;
          25* )             BOP="Life";;
          * )               BOP="Белтелеком";;
        esac
      echo ${TIME[$i]}';'$AOP';'${A1s[$i]}';'$BOP';'375${Bs[$i]}';' >> $RESCSV$RSC
      FRODS=$(($FRODS+1))
    fi
  fi
done
done

rm -f $TMPCSV
echo ""
echo "Done"
