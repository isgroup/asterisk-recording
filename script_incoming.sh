#!/bin/bash
# script_incoming.sh
# Francesco Ongaro (c) 2013-2017
# Generate and email message and attach a QR Code to it

# Variables
TIME="`date +%s`"
CALL_TIME="$1"
CALL_MAILTO="$2"
CALLERID_NUM="$3"
CALLERID_ANI="$4"
CALLERID_DNID="$5"
CALLERID_RDNID="$6"
CALLERID_NAME="$7"
CALL_TIME_HUMAN="`date "+%C%y-%m-%d %H:%M" -d "@$CALL_TIME"`"
MAIL_SERVER=mail.will

# Log the call
echo "$TIME,$CALL_TIME,$MAILTO,$CALLERID_NUM,$CALLERID_ANI,$CALLERID_DNID,$CALLERID_RDNID,$CALLERID_NAME" >> /var/log/asterisk/incoming.log

# Generate a QR Code
TEMP_QRCODE="`mktemp`"
qrencode -o "$TEMP_QRCODE" -s 5 "$CALLERID_NUM"

function numinfo_chie {
	num="`echo "$1" | sed "s/^+39//g"`"
	curl -s "http://chi-e.it/numero?telefono=$num" | html2text | sed -r "s/\*+ ?//g" | grep -v "^$\|^Il numero di\|Di chi e\|^\["
}

# Mail
TEMP_MAIL="`mktemp`"
echo "Incoming call from $CALLERID_NUM on $CALL_TIME_HUMAN" > "$TEMP_MAIL"
echo >> "$TEMP_MAIL"
numinfo_chie "$CALLERID_NUM" >> "$TEMP_MAIL"
echo >> "$TEMP_MAIL"

cat "$TEMP_MAIL" | \
	/etc/asterisk/sendmail.pl \
		"XXX@CHANGEME.TLD" \
		"$CALL_MAILTO" \
		$MAIL_SERVER \
		"Call from $CALLERID_NUM ($CALL_TIME_HUMAN)" \
		"image/png" \
		"$TEMP_QRCODE" \
		"$CALLERID_NUM"".png"

cat "$TEMP_MAIL"

# Cleanup
rm "$TEMP_QRCODE"
rm "$TEMP_MAIL"
