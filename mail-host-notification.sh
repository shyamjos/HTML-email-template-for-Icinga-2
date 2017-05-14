#!/bin/sh
template=`cat <<TEMPLATE
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
    background-color: #a1e2d6;
}
</style>
</head>
<body>

<table>
<th colspan=2 bgcolor=#17B294><center> Server Monitoring</center></th>

<tr>
<td>Notification Type</td>
<td>$NOTIFICATIONTYPE</td>
</tr>
<tr>
<td>Host</td>
<td>$HOSTALIAS</td>
</tr>



<tr>
<td>IP Address</td>
<td>$HOSTADDRESS</td>
</tr>

<tr>
<td>State </td>
<td>$HOSTSTATE</td>
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
<td><a  target="_blank"  href="http://monitoring.example.com/icingaweb2/dashboard#!/icingaweb2/monitoring/host/history?host=$HOSTALIAS"> Open Dashboard </a></td>
</tr>
</table>

</body>
</html>
TEMPLATE
`

/usr/bin/printf "%b" "$template" | mail  -a 'MIME-Version: 1.0' -a 'Content-Type: text/html' -r 'Monitoring Alert <alerts@monitoring.example.com>' -s "$NOTIFICATIONTYPE - $HOSTDISPLAYNAME is $HOSTSTATE" $USEREMAIL

