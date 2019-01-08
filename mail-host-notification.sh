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
  -l HOSTNAME (\$host.name\$)
  -n HOSTDISPLAYNAME (\$host.display_name\$)
  -o HOSTOUTPUT (\$host.output\$)
  -r USEREMAIL (\$user.email\$)
  -s HOSTSTATE (\$host.state\$)
  -t NOTIFICATIONTYPE (\$notification.type\$)

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
while getopts 4:6::b:c:d:f:hi:l:n:o:r:s:t:v: opt
do
  case "$opt" in
    4) HOSTADDRESS=$OPTARG ;;
    6) HOSTADDRESS6=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) LONGDATETIME=$OPTARG ;; # required
    f) MAILFROM=$OPTARG ;;
    h) Help ;;
    i) ICINGAWEB2URL=$OPTARG ;;
    l) HOSTNAME=$OPTARG ;; # required
    n) HOSTDISPLAYNAME=$OPTARG ;; # required
    o) HOSTOUTPUT=$OPTARG ;; # required
    r) USEREMAIL=$OPTARG ;; # required
    s) HOSTSTATE=$OPTARG ;; # required
    t) NOTIFICATIONTYPE=$OPTARG ;; # required
    v) VERBOSE=$OPTARG ;;
   \?) echo "ERROR: Invalid option -$OPTARG" >&2
       Error ;;
    :) echo "Missing option argument for -$OPTARG" >&2
       Error ;;
    *) echo "Unimplemented option: -$OPTARG" >&2
       Error ;;
  esac
done

shift $((OPTIND - 1))

## Keep formatting in sync with mail-service-notification.sh
for P in LONGDATETIME HOSTNAME HOSTDISPLAYNAME HOSTOUTPUT HOSTSTATE USEREMAIL NOTIFICATIONTYPE ; do
	eval "PAR=\$${P}"

	if [ ! "$PAR" ] ; then
		Error "Required parameter '$P' is missing."
	fi
done



#Variables for HTML Template
#############################
SUBJECT="[ $HOSTSTATE ] - $HOSTDISPLAYNAME is $HOSTSTATE"
TITLE="Icinga Server Monitoring"
ICINGAWEBURL="http://YOUR-IP:PORT/icingaweb2/dashboard#!/icingaweb2/monitoring/host/history?host=$HOSTDISPLAYNAME"
FROMNAME="Icinga Alerts"
FROMEMAIL="icinga-alerts@your-company.com"


#Set colors based on alert condition

if [ "$HOSTSTATE" = "DOWN" ]
then
        color=#FF5566

#elif [ "$HOSTSTATE" = "UP" ]
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
    background-color: #fffff;
}
</style>
</head>
<body>

<table>
<th colspan=2 bgcolor=#17B294><center>$TITLE</center></th>

<tr>
<td>Notification Type</td>
<td>$NOTIFICATIONTYPE</td>
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
<td>State </td>
<td bgcolor=$color><b>$HOSTSTATE</b></td>
</tr>

<tr>
<td>Date/Time</td>
<td>$LONGDATETIME</td>
</tr>


<tr>
<td>Additional Info</td>
<td>$HOSTOUTPUT</td>
</tr>

<tr>
<td>Comment</td>
<td>[$NOTIFICATIONAUTHORNAME] : $NOTIFICATIONCOMMENT</td>
</tr>

<tr>
<td>Alert History</td>
<td><a  target="_blank"  href=$ICINGAWEBURL > Open Dashboard </a></td>
</tr>
</table>

</body>
</html>
EOF
`

## Mail Command
/usr/bin/printf "%b" "$NOTIFICATION_MESSAGE" | $MAILBIN -e "set content_type=text/html;" -e "my_hdr From:$FROMNAME <$FROMEMAIL>" -s "$SUBJECT" $USEREMAIL

