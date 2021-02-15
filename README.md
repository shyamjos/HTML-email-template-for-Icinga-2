# HTML email alert template for Icinga 2
simple HTML email alert Template for Icinga 2 to replace the default boring text based email alert.  

Update: I have replaced mail command with mutt due to incompatibility of options among different linux distributions. 
Also I have added new color highlight feature for different states (ok=green,warning=orange and critical=red).
# Screenshot 

![alt text](https://shyamjos.com/assets/img/icinga2/icinga-html-email.png)
![alt text](https://shyamjos.com/assets/img/icinga2/html-template-for-icinga.png)
![alt text](https://shyamjos.com/assets/img/icinga2/icinga-2-html-email-template.png)

# Installation 

Take backup of existing files in `/etc/icinga2/scripts` and copy this new scripts to it 

Edit the "Variables for HTML Template" section in mail-service-notification.sh
```
SUBJECT="$SERVICEDISPLAYNAME $SERVICESTATE! - $HOSTDISPLAYNAME"
TITLE="Icinga Server Monitoring"
ICINGAWEBURL="http://YOUR-IP:PORT/icingaweb2/dashboard#!/icingaweb2/monitoring/service/history?host=$HOSTDISPLAYNAME&service=$SERVICENAME"
FROMNAME="Icinga Alerts"
FROMEMAIL="icinga-alerts@your-company.com" 
```	
Edit the "Variables for HTML Template" section in mail-host-notification.sh
```
SUBJECT="[ $HOSTSTATE ] - $HOSTDISPLAYNAME is $HOSTSTATE"
TITLE="Icinga Server Monitoring"
ICINGAWEBURL="http://YOUR-IP:PORT/icingaweb2/dashboard#!/icingaweb2/monitoring/host/history?host=$HOSTDISPLAYNAME"
FROMNAME="Icinga Alerts"
FROMEMAIL="icinga-alerts@your-company.com" 
```
Complete Tutorial : https://shyamjos.com/icinga2-html-template/
