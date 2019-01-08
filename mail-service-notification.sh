#!/usr/bin/env bash
#
# shyamjos.com (2019)
# Copyright (C) 2012-2018 Icinga Development Team (https://icinga.com/)
# Except of function urlencode which is Copyright (C) by Brian White (brian@aljex.com) used under MIT license

PROG="`basename $0`"
MAILBIN="mutt"

#Check if mutt is installed

if [ -z "`which $MAILBIN`" ] ; then
  echo "$MAILBIN not found in \$PATH. Consider installing it."
  exit 1
fi

## Function helpers
Usage() {
cat << EOF

Required parameters:
  -d LONGDATETIME (\$icinga.long_date_time\$)
  -e SERVICENAME (\$service.name\$)
  -l HOSTNAME (\$host.name\$)
  -n HOSTDISPLAYNAME (\$host.display_name\$)
  -o SERVICEOUTPUT (\$service.output\$)
  -r USEREMAIL (\$user.email\$)
  -s SERVICESTATE (\$service.state\$)
  -t NOTIFICATIONTYPE (\$notification.type\$)
  -u SERVICEDISPLAYNAME (\$service.display_name\$)

Optional parameters:
  -4 HOSTADDRESS (\$address\$)
  -6 HOSTADDRESS6 (\$address6\$)
  -b NOTIFICATIONAUTHORNAME (\$notification.author\$)
  -c NOTIFICATIONCOMMENT (\$notification.comment\$)
  -i ICINGAWEB2URL (\$notification_icingaweb2url\$, Default: unset)
  -f MAILFROM (\$notification_mailfrom\$, requires GNU mailutils (Debian/Ubuntu) or mailx (RHEL/SUSE))
  -v (\$notification_sendtosyslog\$, Default: false)

EOF
}

Help() {
  Usage;
  exit 0;
}

Error() {
  if [ "$1" ]; then
    echo $1
  fi
  Usage;
  exit 1;
}

urlencode() {
  local LANG=C i c e=''
  for ((i=0;i<${#1};i++)); do
    c=${1:$i:1}
    [[ "$c" =~ [a-zA-Z0-9\.\~\_\-] ]] || printf -v c '%%%02X' "'$c"
    e+="$c"
  done
  echo "$e"
}

## Main
while getopts 4:6:b:c:d:e:f:hi:l:n:o:r:s:t:u:v: opt
do
  case "$opt" in
    4) HOSTADDRESS=$OPTARG ;;
    6) HOSTADDRESS6=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) LONGDATETIME=$OPTARG ;; # required
    e) SERVICENAME=$OPTARG ;; # required
    f) MAILFROM=$OPTARG ;;
    h) Usage ;;
    i) ICINGAWEB2URL=$OPTARG ;;
    l) HOSTNAME=$OPTARG ;; # required
    n) HOSTDISPLAYNAME=$OPTARG ;; # required
    o) SERVICEOUTPUT=$OPTARG ;; # required
    r) USEREMAIL=$OPTARG ;; # required
    s) SERVICESTATE=$OPTARG ;; # required
    t) NOTIFICATIONTYPE=$OPTARG ;; # required
    u) SERVICEDISPLAYNAME=$OPTARG ;; # required
    v) VERBOSE=$OPTARG ;;
   \?) echo "ERROR: Invalid option -$OPTARG" >&2
       Usage ;;
    :) echo "Missing option argument for -$OPTARG" >&2
       Usage ;;
    *) echo "Unimplemented option: -$OPTARG" >&2
       Usage ;;
  esac
done

shift $((OPTIND - 1))

## Keep formatting in sync with mail-host-notification.sh
for P in LONGDATETIME HOSTNAME HOSTDISPLAYNAME SERVICENAME SERVICEDISPLAYNAME SERVICEOUTPUT SERVICESTATE USEREMAIL NOTIFICATIONTYPE ; do
        eval "PAR=\$${P}"

        if [ ! "$PAR" ] ; then
                Error "Required parameter '$P' is missing."
        fi
done


#Variables for HTML Template
#############################

SUBJECT="$SERVICEDISPLAYNAME $SERVICESTATE! - $HOSTDISPLAYNAME"
TITLE="Icinga Server Monitoring"
ICINGAWEBURL="http://YOUR-IP:PORT/icingaweb2/dashboard#!/icingaweb2/monitoring/service/history?host=$HOSTDISPLAYNAME&service=$SERVICENAME"
FROMNAME="Icinga Alerts"
FROMEMAIL="icinga-alerts@your-company.com"


#Set colors based on alert condition
 
if [ "$SERVICESTATE" = "CRITICAL" ]
then
	color=#FF5566

elif [ "$SERVICESTATE" = "WARNING" ]
then
	color=#FFAA44

elif [ "$SERVICESTATE" = "UNKNOWN" ]
then
	color=#90A4AE

elif [ "$SERVICESTATE" = "DOWN" ]
then
	color=#FF5566

#else [ "$SERVICESTATE" = "OK" ]
#then
else
	color=#44BB77

fi


## Build the notification message
NOTIFICATION_MESSAGE=`cat << EOF
<!DOCTYPE html>
<html>
<head>
<style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
    width: 100%;
}
td, th {
    border: 1px solid #1bd0b2;
    text-align: left;
    padding: 8px;
}
tr:nth-child(even) {
    background-color: #ffffff;
}
</style>
</head>
<body>
<table>
<th colspan=2 bgcolor=#17B294><center>$TITLE</center></th>
<tr>
<td>Notification Type:</td>
<td>$NOTIFICATIONTYPE</td>
</tr>
<tr>
<td>Service</td>
<td>$SERVICENAME</td>
</tr>
<tr>
<td>Host</td>
<td>$HOSTDISPLAYNAME</td>
</tr>
<tr>
<td>IP Address</td>
<td>$HOSTADDRESS</td>
</tr>
<tr>
<td>State</td>
<td><b>$SERVICESTATE</b></td>
</tr>
<tr>
<td>Date/Time</td>
<td>$LONGDATETIME</td>
</tr>
<tr>
<td>Additional Info</td>
<td bgcolor=$color><b>$SERVICEOUTPUT</b></td>
</tr>
<tr>
<td>Comment</td>
<td>[$NOTIFICATIONAUTHORNAME] : $NOTIFICATIONCOMMENT</td>
</tr>
<tr>
<td>Alert History</td>
<td><a  target="_blank"  href=$ICINGAWEBURL> Open Dashboard </a></td>
</tr>
</table>
</body>
</html>
EOF
`


## Mail Command
/usr/bin/printf "%b" "$NOTIFICATION_MESSAGE" | $MAILBIN -e "set content_type=text/html;" -e "my_hdr From:$FROMNAME <$FROMEMAIL>" -s "$SUBJECT" $USEREMAIL

