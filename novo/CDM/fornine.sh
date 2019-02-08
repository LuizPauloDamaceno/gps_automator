YEAR=$(date "+%y"); #Dois últimos dígitos do ano
MONTH=$(date "+%m");
MONTH_SAVE=$(cat month.txt) #Pega o valor do último mês atualizado
FILENAME=$(printf "CDLR__%s.%s_" $YEAR $MONTH) #Formata o nome do arquivo
MJD=$(cat /var/log/ntpstats/peerstats | sed '$!d' | awk '{print $1}') #Pega dia MJD da ultima linha do arquivo
LASTDIG=$(echo "${MJD: -1}") #Pega o ultimo digito do dia MJD

if [ "$MONTH_SAVE" -eq "$MONTH" ]; then
	echo "-> O mês ainda não mudou, tentando ler ClockData do dia!"

	if [ "$LASTDIG" -eq "4" ] || [ "$LASTDIG" -eq "9" ]; then
		daydiff=$(cat ~/automatizador_gps/contador_leitura/bipm_measure/bipm_counter.txt)
		echo "-> Dia MJD pelo daemon NTP:" $MJD
		echo "-> Guardando novo valor do ClockData: " $daydiff
		(printf "%s" $MJD; printf "%s" " 10016 1353028 "; printf "%09s\n"  $daydiff) >> information_clockdata.txt
	fi

	if [ "$LASTDIG" -ne "4" ] && [ "$LASTDIG" -ne "9" ]; then
		echo "-> Dia MJD pelo daemon NTP:" $MJD
		echo "-> Geracao limitada aos dias MJD com final 4 e 9! Final atual:" $LASTDIG
	fi
fi

if [ "$MONTH" -gt "$MONTH_SAVE" ]; then
	echo $MONTH > month.txt
	echo "-> Mudanca de mes, fechar arquivo mensal"
	mv information_clockdata.txt output/$FILENAME
	cd output
	echo "-> Enviando clockdata mensal"
	wput ftp://put_your_address_here $FILENAME
fi
