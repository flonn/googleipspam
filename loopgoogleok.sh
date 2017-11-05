# Loops to check if google suspects spam from the WAN IP and in case: disconnect WAN via Fritzbox router in order to get a new public ipv4 address
 
while [ true ]; do 

if [ $(date +%H) -eq "03" ] ; then  # WAN is disconnected every 24 hours - so only check at a certain hour 
# Runs on a system without cron
	echo "START LOOP--- uhrzeit stimmt" >> status.log
	googleworks=1
	while [ $googleworks -eq "1" ]; do
# loop disconnect function until an unblocked connection is up
		date >> status.log
		curl http://ipconfig.io/ >> status.log
# disconnects the WAN on fritzbox router
		curl "http://192.168.178.1:49000/igdupnp/control/WANIPConn1" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANIPConnection:1#ForceTermination" -d "<?xml version='1.0' encoding='utf-8'?> <s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'> <s:Body> <u:ForceTermination xmlns:u='urn:schemas-upnp-org:service:WANIPConnection:1' /> </s:Body> </s:Envelope>"
		sleep 20
		curl -s http://ipconfig.io/ >> status.log
# new ip
		if [ $(curl -I https://www.google.de/search?q=test 2>/dev/null | head -n 1 | cut -d$' ' -f2) -eq "403" ] ; then echo "works"; googleworks=0; fi
# magic: if curl return code is forbidden (403) that means OK, since google does not like curl
#        status code forward (200) is used to forward to captcha (which means that google is not working)	 
	done

	echo "ENDE LOOP---" >> status.log

	sleep 3600

else
	sleep 3600

	fi

done
