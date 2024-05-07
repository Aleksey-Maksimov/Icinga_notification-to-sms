#!/bin/sh
#
# Script for SMS notifications for Icinga
# Aleksey Maksimov <aleksey.maksimov@it-kb.ru>
#
# Tested on:
# - Debian GNU/Linux 8.8 (Jessie) with Icinga r2.6.3-1, SMS Server Tools (smsd) 3.1.15
# - Debian GNU/Linux 9.12 (Stretch) with Icinga r2.11.4-1, SMS Server Tools (smsd) 3.1.15
#
# Put here /etc/icinga2/scripts/notification-to-sms.sh 
#
# 2017.09.27 - Initial version
# 2020.07.12 - Added output truncation for --service-state option
#
PLUGIN_NAME="Plugin for SMS notifications for Icinga Director"
PLUGIN_VERSION="2020.07.12"
PRINTINFO=`printf "\n%s, version %s\n \n" "$PLUGIN_NAME" "$PLUGIN_VERSION"`
#
#
Usage() {
  echo "$PRINTINFO"
  echo "Usage: $0 [OPTIONS]

Option   GNU long option         Meaning
------   ---------------	 -------
 -M      --plugin-mode           Plugin mode. Static value. Possible values: host-mode|service-mode
 -a      --notification-type	 Icinga Notification type (for example, from a variable \$notification.type\$)
 -b      --notification-autor	 Icinga Notification autor (for example, from a variable \$notification.author\$)
 -c      --notification-comment  Icinga Notification comment (for example, from a variable \$notification.comment\$)
 -d      --long-datetime	 Icinga Notification date and time (for example, from a variable \$icinga.long_date_time\$)
 -e      --host-displayname	 Icinga Host name (for example, from a variable \$host.display_name\$)
 -f      --host-alias		 Icinga Host alias (for example, from a variable \$host.name\$)
 -g      --host-address		 Icinga Host address (for example, from a variable \$address\$)
 -h      --host-state		 Icinga Host last state (for example, from a variable \$host.state\$)
 -i      --host-output		 Icinga Host monitoring plugin output (for example, from a variable \$host.output\$)
 -j      --service-displayname   Icinga Service display name (for example, from a variable \$service.display_name\$)
 -k      --service-desc		 Icinga Service alias (for example, from a variable \$service.name\$)
 -l      --service-state	 Icinga Service last state (for example, from a variable \$service.state\$ )
 -m      --service-output	 Icinga Service monitoring plugin output (for example, from a variable \$service.output\$)
 -z      --item-comment          Additional item comment with custom variable from Host or Service (for example, from a variable \$host.Notification_Comment\$)
 -n      --sms-to		 Email address for "To:" header (for example, from a variable \$user.pager\$)
 -q      --help                  Show this message
 -v      --version		 Print version information and exit

"
}
#
# Parse arguments
#
OPTS=`getopt -o M:a:b:c:d:e:f:g:h:i:j:k:l:m:z:n:qv -l plugin-mode:,notification-type:,notification-autor:,notification-comment:,long-datetime:,host-displayname:,host-alias:,host-address:,host-state:,host-output:,service-displayname:,service-desc:,service-state:,service-output:,item-comment:,sms-to:,help,version -- "$@"`
eval set -- "$OPTS"
while true; do
        case $1 in
                -M|--plugin-mode)
      			case "$2" in
                        "host-mode"|"service-mode") PLUGINMODE=$2 ; shift 2 ;;
                                                 *) printf "Unknown value for option %s. Use 'host-mode' or 'service-mode'\n" "$1" ; exit 1 ;;
			esac ;;
                -a|--notification-type)
                        NOTIFICATIONTYPE=$2 ; shift 2 ;;
                -b|--notification-autor)
                        NOTIFICATIONAUTHORNAME=$2 ; shift 2 ;;
                -c|--notification-comment)
                        NOTIFICATIONCOMMENT=$2 ; shift 2 ;;
                -d|--long-datetime)
                        LONGDATETIME=$2 ; shift 2 ;;
                -e|--host-displayname)
                        HOSTDISPLAYNAME=$2 ; shift 2 ;;
                -f|--host-alias)
                        HOSTALIAS=$2 ; shift 2 ;;
                -g|--host-address)
                        HOSTADDRESS=$2 ; shift 2 ;;
                -h|--host-state)
                        HOSTSTATE=$2 ; shift 2 ;;
                -i|--host-output)
                        HOSTOUTPUT=$2 ; shift 2 ;;
                -j|--service-displayname)
                        SERVICEDISPLAYNAME=$2 ; shift 2 ;;
                -k|--service-desc)
                        SERVICEDESC=$2 ; shift 2 ;;
                -l|--service-state)
                        SERVICESTATE=$2 ; shift 2 ;;
                -m|--service-output)
                        SERVICEOUTPUT=$2 ; shift 2 ;;
                -z|--item-comment)
                        ITEMCOMMENT=$2 ; shift 2 ;;
                -n|--sms-to)
                        SMSTO=$2 ; shift 2 ;;
                -q|--help)
                        Usage ; exit 0 ;;
                -v|--version)
			echo "$PRINTINFO" ; exit 0 ;;
                --)
                        # no more arguments to parse
                        shift ; break ;;
                *)
                        printf "\nUnrecognized option %s\n\n" "$1" ; Usage ; exit 1 ;;
        esac 
done
#
#
TIMETOSMS=`echo $(date -d "$LONGDATETIME" +"%d.%m.%Y %T %Z")`
#
#
ITEMCOMMENTTOSMS=""
if [ -n "$ITEMCOMMENT" ]; then
ITEMCOMMENTTOSMS=`echo Data: $ITEMCOMMENT`
fi
#
#
COMMENTTOSMS=""
if [ -n "$NOTIFICATIONAUTHORNAME" ]; then 
COMMENTTOSMS=`echo Comment: $NOTIFICATIONAUTHORNAME : $NOTIFICATIONCOMMENT`
fi
#
#
if [ "$PLUGINMODE" = "host-mode" ]; then
	#
template=`cat <<TEMPLATE
Icinga $NOTIFICATIONTYPE 
Host: $HOSTDISPLAYNAME ($HOSTADDRESS)
Info: $HOSTOUTPUT
Time: $TIMETOSMS
$ITEMCOMMENTTOSMS
$COMMENTTOSMS
TEMPLATE
`
	#
	#
elif [ "$PLUGINMODE" = "service-mode" ]; then
	#
	if [ -n "$SERVICEOUTPUT" ]; then
	SERVICEOUTPUTTOSMS=`echo $SERVICEOUTPUT | cut -c1-100`
	fi
	#
template=`cat <<TEMPLATE
Icinga $NOTIFICATIONTYPE
Host: $HOSTDISPLAYNAME
Service: $SERVICEDESC
State: $SERVICEOUTPUTTOSMS
Time: $TIMETOSMS
$ITEMCOMMENTTOSMS
$COMMENTTOSMS
TEMPLATE
`
	#
	#
fi
#
# Send sms to smsd queue
#
SMSDFILE=/var/spool/sms/outgoing/`date +%Y%m%d-%Hh-%Mm-%Ss-%Nns`
/usr/bin/printf "To: $SMSTO\n\n$template" > $SMSDFILE
/bin/chmod a+r $SMSDFILE
#
#
