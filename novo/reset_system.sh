ACMTYPE=$(ls /dev/ | grep ACM)
if [ "$ACMTYPE" != "ttyACM0" ]; then
mv /dev/$ACMTYPE /dev/ttyACM0
echo "changed. I'm saved your life xD"
fi
echo "nothing to change."

#killall rxtools
