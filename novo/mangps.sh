#!/bin/sh

echo Inicializando...

read -p "Insira o dia do ano desejado: " DOY
DOYN=$(echo $DOY)0;
read -p "Insira os dois ultimos digitos do ano desejado: " YY
read -p "Insira o MJD correspondente: " MJD

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
find -type f -iname "LRTE$DOYN.$YY""_" -exec cp -n {} /home/clock/ArquivosSBF/crude/ \;
find -type f -iname "LRTE$DOYN.$YY""_" -exec cp -n {} /home/clock/ArquivosSBF/backup_sbf/ \;

#Ache o arquivo para processamento!
cd /home/clock/ArquivosSBF/crude/

sleep 0.5

FILE=$(ls | grep *."$YY""_");

#Execução de scripts para conversão
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -nN -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo de navegação 
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -nG -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo GPS
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -nE -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo GALILEO
/opt/Septentrio/RxTools/bin/sbf2rin -f $FILE -R3 >> /home/clock/automatizador_gps/autolog.txt; #Gera Arquivo de Observação

echo Processando...

OBS=$(ls | grep *."$YY"O); #Arquivo de observação
sleep 0.25
NAV=$(ls | grep *."$YY"N); #Arquivo de navegação
sleep 0.25
GPS=$(ls | grep *."$YY"G); #Arquivo GPS
sleep 0.25
GAL=$(ls | grep *."$YY"L); #Arquivo GALILEO
sleep 0.25

cp *."$YY"O /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/rinex_obs; #Copia Arquivo de observação
cp *."$YY"N /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/rinex_nav_gps; #Copia Arquivo de Navegação 
cp *."$YY"G /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/rinex_nav_glo; #Copia Arquivo GPS
cp *."$YY"L /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/rinex_nav_gal; #Copia Arquivo GALILEO

cp *."$YY"O /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_obs; #Copia arquivo de Observação
cp *."$YY"N /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_nav_gps; #Copia arquivo de Navegação
cp *."$YY"G /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_nav_glo; #Copia arquivo GPS
cp *."$YY"L /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_nav_gal; #Copia arquivo GALILEO

#Conversão para gzip (somente observation)
gzip -S .Z $OBS;

cp *.Z /home/clock/Arquivos_RINEX/GZ_ParaFTP/;

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

DOYIN=$DOY

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
MJDP=$(($MJD)); #Acrescentar -1 se necessário (subtrair um)
sleep 0.25
MJDFORMAT=$(echo 'scale=3; '$MJDP'/1000' | bc -l) #Nomeia para o arquivo calculado
sleep 0.25

echo "Dia MJD: "$MJDP >> /home/clock/automatizador_gps/autolog.txt #Escreve MJD Atual no arquivo de log

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

echo "Obtendo código P1 do dia" >> /home/clock/automatizador_gps/autolog.txt

#Obtem o clockbias
rm -rf P1C1.DCB
rm -rf biasC1P1.dat
wget ftp://ftp.aiub.unibe.ch/CODE/P1C1.DCB >> /home/clock/automatizador_gps/autolog.txt;
sed -n '/G54/q;p' P1C1.DCB > biasC1P1.dat

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

cat biasC1P1.dat >> /home/clock/automatizador_gps/autolog.txt;

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

echo "Feito! Continuando a conversão..." >> /home/clock/automatizador_gps/autolog.txt

echo "Conversor RINEX2CGGTTS:" >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

#Executa programa que converte RINEX em CGGTTS
./conversor_v8 >> /home/clock/automatizador_gps/autolog.txt

echo "Envio FTP:" >> /home/clock/automatizador_gps/autolog.txt

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

#Copia e limpa CGGTTS do GPS
mv CGGTTS_GPS_L3P GZLRRC$MJDFORMAT
cp GZLRRC$MJDFORMAT out/
sleep 0.15
rm -rf GZLR$MJDFORMAT
sleep 0.15

#Copia e limpa CGGTTS do GLONASS (Doesnt needed)
#mv CGGTTS_GLO_L3P RZLRRC$MJDFORMAT
#cp RZLRRC$MJDFORMAT out/
#sleep 0.15
#rm -rf RZLR$MJDFORMAT
#sleep 0.15

#Copia os arquivos convertidos para o servidor FTP e os remove, preparando o diretorio para novos arquivo.
cd out

sleep 2

wput ftp://put_your_address_here GZLRRC$MJDFORMAT >> /home/clock/automatizador_gps/autolog.txt

#sleep 2

wput ftp://put_your_address_here GZLRRC$MJDFORMAT >> /home/clock/automatizador_gps/autolog.txt

#sleep 2

# Envia os arquivos .gz da pasta "Arquivos_RINEX/GZ_PARAFTP" para o servidor FTP
cd /home/clock/Arquivos_RINEX/GZ_ParaFTP/

#sleep 2

wput ftp://put_your_address_here *"$YY"O.Z >> /home/clock/automatizador_gps/autolog.txt

#sleep 2

wput ftp://put_your_address_here *"$YY"O.Z >> /home/clock/automatizador_gps/autolog.txt

sleep 2

echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

#Remove arquivos convertidos
cd /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/;
rm -rf CGGTTS_BDS_B1 CGGTTS_BDS_L3B CGGTTS_GAL_E1 CGGTTS_GAL_L3E CGGTTS_GLO_C1 CGGTTS_GLO_L3P CGGTTS_GLO_P1 CGGTTS_GPS_C1 CGGTTS_GPS_L3P CGGTTS_GPS_P1 CGGTTS.mix CTTS_BDS_30s_B1 CTTS_BDS_30s_B2 CTTS_BDS_30s_L3B CTTS_GAL_30s_E1 CTTS_GAL_30s_E5 CTTS_GAL_30s_E5a CTTS_GAL_30s_E5b CTTS_GAL_30s_L3E CTTS_GLO_30s_C1 CTTS_GLO_30s_C2 CTTS_GLO_30s_L3P CTTS_GLO_30s_P1 CTTS_GLO_30s_P2 CTTS_GPS_30s_C1 CTTS_GPS_30s_C2 CTTS_GPS_30s_C5 CTTS_GPS_30s_L3P CTTS_GPS_30s_P1 CTTS_GPS_30s_P2

#Limpa todo diretorio de saida CGGTTS
rm -rf /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/out/*.*

#Limpa todo diretorio de saida RINEX
rm -rf /home/clock/Arquivos_RINEX/GZ_ParaFTP/*.*

#TESTE

#Realiza cópia dos arquivos do dia anterior para a pasta de conversão.
cd /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/last_day/;
cp rinex_obs /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_obs_p;
cp rinex_nav_gps /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_nav_p_gps;
cp rinex_nav_glo /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_nav_p_glo;
cp rinex_nav_gal /home/clock/Arquivos_RINEX/GZ_ParaCGGTTS/rinex_nav_p_gal;


echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

#echo "Envido do arquivo ClockData diario: " >> /home/clock/automatizador_gps/autolog.txt

#echo "------------------------------------------------------------------------" >> /home/clock/automatizador_gps/autolog.txt

sleep 0.25

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
