#!/bin/sh
# script_monitoring.sh
# Francesco Ongaro (c) 2013-2017
# Record calls, generate a spectrogram, mail them

TIME="`date +%s`"
MAIL_SERVER=CHANGEME

LEFT="$1"
RIGHT="$2"
OUT="`echo "$3"|sed "s/.wav//"`"

LEFT_OGG="`echo "$LEFT"|sed "s/.wav//"`.ogg"
RIGHT_OGG="`echo "$RIGHT"|sed "s/.wav//"`.ogg"

CALL_FROM="`echo $OUT | cut -d "_" -f3`"
CALL_TIME="`echo $OUT | cut -d "_" -f2`"
CALL_TIME_HUMAN="`date "+%C%y-%m-%d %H:%M" -d "@$CALL_TIME"`"

CALLERID_NUM="$CALL_FROM"
CALL_MAILTO=XXX@CHANGEME.TLD

# Log the call
echo "$TIME,$CALL_TIME,$CALL_FROM" >> /var/log/asterisk/monitor.log

test ! -r "$LEFT" && exit 21
test ! -r "$RIGHT" && exit 22

# Create a spectrogram with high contrast of the caller side
sox "$LEFT" -n spectrogram -z 50 -Y 130 -l -r -o "$LEFT"".png"

# Convert mono to stereo, adjust balance to -1/1, combine and compress
nice -n 10 sox -M "$LEFT" "$RIGHT" "$OUT.ogg"

# Convert from WAV to OGG and delete old files
nice -n 10 sox "$LEFT" "$LEFT_OGG"
nice -n 10 sox "$RIGHT" "$RIGHT_OGG"
#rm "$LEFT" "$RIGHT"

# Mail
echo "Recording of $CALLERID_NUM on $CALL_TIME_HUMAN" | \
	/etc/asterisk/sendmail.pl \
		"XXX@CHANGEME.TLD" \
		"$CALL_MAILTO" \
		$MAIL_SERVER \
		"Recording of $CALLERID_NUM ($CALL_TIME_HUMAN)" \
		"audio/ogg" \
		"$OUT.ogg" \
		"$CALLERID_NUM""_""$CALL_TIME"".ogg" \
		"audio/ogg" \
		"$LEFT_OGG" \
		"left_""$CALLERID_NUM""_""$CALL_TIME"".ogg" \
		"audio/ogg" \
		"$RIGHT_OGG" \
		"right_""$CALLERID_NUM""_""$CALL_TIME"".ogg" \
		"image/png" \
		"$LEFT"".png" \
		"left_""$CALLERID_NUM""_""$CALL_TIME"".png"
