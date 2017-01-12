# asterisk-recording
Monitoring and recording scripts for Asterisk

## extensions.conf

```
[globals]
MONITOR_EXEC=/etc/asterisk/script_monitor.sh
```

## extensions.conf

```
[sipin]
exten => 901,1,Answer()
exten => 901,n,Set(CALLFILENAME=901_${EPOCH}_${CALLERID(num)})
exten => 901,n,Monitor(wav,${CALLFILENAME},m)
exten => 901,n,set(CHANNEL(musicclass)=isgroup)
exten => 901,n,Log(NOTICE,Incoming call,CID:${CALLERID(num)})
exten => 901,n,System(/etc/asterisk/script_incoming.sh "${EPOCH}" "XXX@CHANGEME.TLD" "${CALLERID(num)}" "${CALLERID(ani)}" "${CALLERID(dnid)}" "${CALLERID(rdnis)}" "${CALLERID(name)}")
exten => 901,n,GotoIf($["${CALLERID(num)}" = ""]?1000,1:1001,1)
```
