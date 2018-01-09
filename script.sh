#!/bin/sh

echo Inicializando...

dia=$(date);

echo "************************************************************************" > /home/clock/automatizador_gps/autolog.txt
echo "LOG DE EXECUÇÃO DO SCRIPT - $dia" >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt
rm -rf /home/clock/Arquivos_RINEX/GZ_ParaFTP/*.*
rm -rf /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/out/*.*

sleep 0.5

cd /home/clock/DATA/

sleep 0.5

#COMANDOS INICIAIS PARA ENCONTRAR O ARQUIVO A SER PROCESSADO NO DIA E COPIÁ-LO FAZENDO BACKUP.
DOY=$(date "+%j");
#DOYN=$((($DOY)*10)); This sucks.
DOYN=$(date "+%j")0; #CORRECT, WHY RXTOOLS DO THIS BULLSHIT????
find -type f -iname "LRTE$DOYN.18_" -exec cp -n {} /home/clock/ArquivosSBF/crude/ \;
find -type f -iname "LRTE$DOYN.18_" -exec cp -n {} /home/clock/ArquivosSBF/backup_sbf/ \;

#Ache o arquivo para processamento!
cd /home/clock/ArquivosSBF/crude/

sleep 0.5

FILE=$(ls | grep *.18_);

#Execução de scripts para conversão
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -nN -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo de navegação 
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -nG -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo GPS
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -nE -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo GALILEO
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo de Observação

echo Processando...

OBS=$(ls | grep *.18O); #Arquivo de observação
sleep 0.25
NAV=$(ls | grep *.18N); #Arquivo de navegação
sleep 0.25
GPS=$(ls | grep *.18G); #Arquivo GPS
sleep 0.25
GAL=$(ls | grep *.18L); #Arquivo GALILEO
sleep 0.25

cp *.18O /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/; #Copia Arquivo de observação
cp *.18N /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/; #Copia Arquivo de Navegação 
cp *.18G /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/; #Copia Arquivo GPS
cp *.18L /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/; #Copia Arquivo GALILEO

cp *.18O /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/; #Copia arquivo de Observação
cp *.18N /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/; #Copia arquivo de Navegação
cp *.18G /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/; #Copia arquivo GPS
cp *.18L /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/; #Copia arquivo GALILEO

#Conversão para gzip (somente observation)
gzip -c $OBS > $OBS.gz;

cp *.gz /home/clock/Arquivos_RINEX/GZ_ParaFTP/;

rm -rf /home/clock/ArquivosSBF/crude/*

echo "Conversor sbf2rin e Gzip executados com sucesso!" >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt


###### SUBSCRIPT PARA CRIAÇAO DE ARQUIVO inputFile.dat do conversor CGGTTS ######

cd /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;

sleep 0.5

#DOY=$(date "+%j");
#sleep 0.25
#DOYP=0$(($(date "+%j")-1))0;

DOYIN=0
DOYP=0

DOYIN=$(date "+%j");

if [ $DOYIN -lt 10 ] && [ $DOYIN -le 99 ]; then
        DOYP=0$(echo "($DOYIN-1)" | bc)
        DOYPO=$(echo 0"$DOYP"0)
	DOY=0$(echo "($DOYIN)" | bc)
        DOYO=$(echo 0"$DOY"0)
	echo Usando caso 1 para gerar os parâmetros. >> /home/clock/automatizador_gps/autolog.txt
fi

if [ $DOYIN -gt 10 ] && [ $DOYIN -lt 99 ]; then
	DOYP=0$(echo "($DOYIN-1)*10" | bc)
	DOYPO=$(echo "$DOYP")
	DOY=0$(echo "($DOYIN)*10" | bc)
        DOYO=$(echo "$DOY")
	echo Usando caso 2 para gerar os parâmetros. >> /home/clock/automatizador_gps/autolog.txt
fi

if [ $DOYIN -gt 99 ] && [ $DOYIN -lt 100 ] || [ $DOYIN -gt 100 ]; then 
	DOYP=$(echo "$DOYIN-11+10" | bc)
	DOYPO=$(echo "$DOYP"0)
	DOY=$(echo "$DOYIN" | bc)
        DOYO=$(echo "$DOY"0)
	echo Usando caso 3 para gerar os parâmetros. >> /home/clock/automatizador_gps/autolog.txt
fi

if [ $DOYIN -eq 99 ]; then 
        DOYP=$(echo "($DOYIN-1)*10" | bc)
        DOYPO=$(echo 0"$DOYP")
	DOY=$(echo "($DOYIN)*10" | bc)
        DOYO=$(echo 0"$DOY")
	echo Usando caso 4 para gerar os parâmetros. >> /home/clock/automatizador_gps/autolog.txt

fi

if [ $DOYIN -eq 100 ]; then 
        DOYP=$(echo "($DOYIN-1)*10" | bc)
        DOYPO=$(echo 0"$DOYP")
        DOY=$(echo "($DOYIN)" | bc)
        DOYO=$(echo "$DOY"0)
	echo Usando caso 5 para gerar os parâmetros. >> /home/clock/automatizador_gps/autolog.txt
fi

if [ $DOYIN -eq 10 ] ; then
        DOYP=0$(echo "($DOYIN-1)*10" | bc)
        DOYPO=$(echo 0"$DOYP")
        DOY=0$(echo "($DOYIN)*10" | bc)
        DOYO=$(echo "$DOY")
	echo Usando caso 6 para gerar os parâmetros. >> /home/clock/automatizador_gps/autolog.txt
fi

sleep 0.25
MJD=$(echo $(($(date "+%s")/86400+40586)));
sleep 0.25
MJDP=$(($MJD-1));
sleep 0.25
MJDFORMAT=$(echo 'scale=3; '$MJDP'/1000' | bc -l)
sleep 0.25

#Padrão para dia atual
#Gera Observação

printf "FILE_RINEX_OBS\n" > inputFile.dat
printf "LRTE%s.18O\n" $DOYPO >> inputFile.dat
printf "FILE_RINEX_OBS_P\n" >> inputFile.dat
printf "LRTE%s.18O\n" $DOYO >> inputFile.dat

sleep 0.25

#Gera Navegação GPS

printf "FILE_RINEX_NAV_GPS\n" >> inputFile.dat
printf "LRTE%s.18N\n" $DOYPO >> inputFile.dat
printf "FILE_RINEX_NAV_P_GPS\n" >> inputFile.dat
printf "LRTE%s.18N\n" $DOYO >> inputFile.dat

sleep 0.25

#Gera Navegação GLONASS

printf "FILE_RINEX_NAV_GLO\n" >> inputFile.dat
printf "LRTE%s.18G\n" $DOYPO >> inputFile.dat
printf "FILE_RINEX_NAV_P_GLO\n" >> inputFile.dat
printf "LRTE%s.18G\n" $DOYO >> inputFile.dat

sleep 0.25

#Gera Navegação GALILEO

printf "FILE_RINEX_NAV_GAL\n" >> inputFile.dat
printf "LRTE%s.18L\n" $DOYPO >> inputFile.dat
printf "FILE_RINEX_NAV_P_GAL\n" >> inputFile.dat
printf "LRTE%s.18L\n" $DOYO >> inputFile.dat

sleep 0.25

printf "FILE_CGGTTS_LOG\n" >> inputFile.dat
printf "CGGTTS%s.LOG\n" $MJDP >> inputFile.dat

sleep 0.25

#CGGTTS GPS

printf "FILE_CGGTTS_GPS\n" >> inputFile.dat
printf "GZLRRC%s\n" $MJDFORMAT >> inputFile.dat

sleep 0.25

#CGGTTS GLO
printf "FILE_CGGTTS_GLO\n" >> inputFile.dat
printf "RZLRRC%s\n" $MJDFORMAT >> inputFile.dat

sleep 0.25

#CGGTTS GAL
printf "FILE_CGGTTS_GAL\n" >> inputFile.dat
printf "EZLRRC%s\n" $MJDFORMAT >> inputFile.dat

sleep 0.25

printf "MODIFIED_JULIAN_DAY\n" >> inputFile.dat
printf "%s\n" $MJDP >> inputFile.dat

echo "Dia MJD: "$MJDP >> /home/clock/automatizador_gps/autolog.txt #Escreve MJD Atual no arquivo de log

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

echo "Conversor rin2cggtts:" >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

####FIM DO SCRIPT DE CRIAÇAO DO ARQUIVO "inputFile.dat"####

#Executa programa que converte RINEX em CGGTTS
./conversor_v7 >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

echo "Envio FTP:" >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

#Copia e limpa CGGTTS do GALILEO
#cp EZLRRC$MJDFORMAT out/
sleep 0.15
rm -rf EZLR$MJDFORMAT
sleep 0.15

#Copia e limpa CGGTTS do GPS
cp GZLRRC$MJDFORMAT out/
sleep 0.15
rm -rf GZLR$MJDFORMAT
sleep 0.15

#Copia e limpa CGGTTS do GLONASS
cp RZLRRC$MJDFORMAT out/
sleep 0.15
rm -rf RZLR$MJDFORMAT
sleep 0.15


cp CGGTTS$MJDP.LOG LOGS/
sleep 0.15
rm -rf CGGTTS$MJDP.LOG

#Copia os arquivos convertidos para o servidor FTP e os remove, preparando o diretorio para novos arquivo.
cd out
wput ftp://PUT FTP DATA HERE *.* >> /home/clock/automatizador_gps/autolog.txt

sleep 2

wput ftp://PUT FTP DATA HERE *.* >> /home/clock/automatizador_gps/autolog.txt

sleep 2

wput ftp://PUT FTP DATA HERE *.* >> /home/clock/automatizador_gps/autolog.txt

sleep 2

# Envia os arquivos .gz da pasta "Arquivos_RINEX/GZ_PARAFTP" para o servidor FTP
cd /home/clock/Arquivos_RINEX/GZ_ParaFTP/
wput ftp://PUT FTP DATA HERE *18O.gz >> /home/clock/automatizador_gps/autolog.txt

sleep 2

wput ftp://PUT FTP DATA HERE *18O.gz >> /home/clock/automatizador_gps/autolog.txt

sleep 2

wput ftp://PUT FTP DATA HERE *18O.gz >> /home/clock/automatizador_gps/autolog.txt

sleep 2

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

#Remove arquivos do dia anterior (se houver)
cd /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;

REMOVE1=$(printf "LRTE%s.18N\n" $DOYPO);

rm -rf $REMOVE1;

REMOVE2=$(printf "LRTE%s.18G\n" $DOYPO);

rm -rf $REMOVE2;

REMOVE3=$(printf "LRTE%s.18O\n" $DOYPO);

rm -rf $REMOVE3;

REMOVE4=$(printf "LRTE%s.18L\n" $DOYPO);

rm -rf $REMOVE4;


#Limpa todo diretorio de saida CGGTTS
rm -rf /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/out/*.*

#Limpa todo diretorio de saida RINEX
rm -rf /home/clock/Arquivos_RINEX/GZ_ParaFTP/*.*

#TESTE

#Obtem o dia da semana atual e o dia da semana anterior
#DOY=$(date "+%j");
#DOYP0=0$(($DOY-1));

#Realiza cópia dos arquivos do dia anterior para a pasta de conversão.
cd /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/;
cp *.18O /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;
cp *.18N /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;
cp *.18G /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;
cp *.18L /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;



#Remove arquivos do dia de hoje
cd /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;

REMOVE1=$(printf "LRTE%s.18N\n" $DOYPO);

rm -rf $REMOVE1;

REMOVE2=$(printf "LRTE%s.18G\n" $DOYPO);

rm -rf $REMOVE2;

REMOVE3=$(printf "LRTE%s.18O\n" $DOYPO);

rm -rf $REMOVE3;

REMOVE4=$(printf "LRTE%s.18L\n" $DOYPO);

rm -rf $REMOVE4;


#Remove arquivos do dia anterior obsoletos

cd /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day;

REMOVE1=$(printf "LRTE%s.18N\n" $DOYO);

rm -rf $REMOVE1;

REMOVE2=$(printf "LRTE%s.18G\n" $DOYO);

rm -rf $REMOVE2;

REMOVE3=$(printf "LRTE%s.18O\n" $DOYO);

rm -rf $REMOVE3;

REMOVE4=$(printf "LRTE%s.18L\n" $DOYO);

rm -rf $REMOVE4;

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

echo "Envido do arquivo ClockData diario: " >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

sleep 0.25

cd /home/clock/automatizador_gps/

#ClockData
MJD=$(echo $(($(date "+%s")/86400+40587)));
MJDFORMAT=$(echo 'scale=3; '$MJD'/1000' | bc -l);
FILENAME=$(printf "CDLR__%s" $MJDFORMAT)

printf "%s 10016 1353028       0.0" $MJD > $FILENAME

#Fazer o FTP para a pasta Clocks
wput ftp://PUT FTP DATA HERE $FILENAME >> /home/clock/automatizador_gps/autolog.txt

wput ftp://PUT FTP DATA HERE $FILENAME >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

echo "PROCESSAMENTO E ENVIO TERMINADOS!" >> /home/clock/automatizador_gps/autolog.txt

echo "************************************************************************" >> /home/clock/automatizador_gps/autolog.txt

cd /home/clock/automatizador_gps/

#Enviando email com o LOG de execução
logcat=$(cat autolog.txt)
echo "$logcat" | mail -s "Envio de dados" luizpauloeletrico42@gmail.com

echo Terminado!!!

sleep 1

rm -rf autolog.txt
sleep 0.25
rm -rf $FILENAME
