## About

**notification-to-sms** - Script for SMS notifications (Host and Service) for Icinga
 
Tested on **Debian GNU/Linux 8.8 (Jessie)** with **Icinga r2.6.3-1**, **SMS Server Tools (smsd) 3.1.15**

Put here: /etc/icinga2/scripts/notification-to-sms.sh 
 
## Usage

Options:

```
$ ./notification-to-sms.sh [OPTIONS]

Option  GNU long option         Meaning
------  ---------------	        -------
-M      --plugin-mode           Plugin mode. Static value. 
                                Possible values: host-mode|service-mode
-a      --notification-type     Icinga Notification type 
                                (for example, from a variable \$notification.type\$)
-b      --notification-autor    Icinga Notification autor 
                                (for example, from a variable \$notification.author\$)
-c      --notification-comment  Icinga Notification comment 
                                (for example, from a variable \$notification.comment\$)
-d      --long-datetime         Icinga Notification date and time 
                                (for example, from a variable \$icinga.long_date_time\$)
-e      --host-displayname      Icinga Host name 
                                (for example, from a variable \$host.display_name\$)
-f      --host-alias            Icinga Host alias
                                (for example, from a variable \$host.name\$)
-g      --host-address          Icinga Host address 
                                (for example, from a variable \$address\$)
-h      --host-state            Icinga Host last state 
                                (for example, from a variable \$host.state\$)
-i      --host-output           Icinga Host monitoring plugin output 
                                (for example, from a variable \$host.output\$)
-j      --service-displayname   Icinga Service display name 
                                (for example, from a variable \$service.display_name\$)
-k      --service-desc          Icinga Service alias 
                                (for example, from a variable \$service.name\$)
-l      --service-state         Icinga Service last state 
                                (for example, from a variable \$service.state\$ )
-m      --service-output        Icinga Service monitoring plugin output 
                                (for example, from a variable \$service.output\$)
-z      --item-comment          Additional item comment with custom variable from Host or Service 
                                (for example, from a variable \$host.Notification_Comment\$)
-n      --sms-to                Email address for "To:" header 
                                (for example, from a variable \$user.pager\$)
-q      --help                  Show this message
-v      --version               Print version information and exit

```

Testing for Host mode:

```
# ./notification-to-sms.sh --plugin-mode 'host-mode' \
--notification-type 'PROBLEM' \ 
--host-displayname 'UPS01' --host-address '10.1.1.6' \
--host-output 'CRITICAL - Host Unreachable (1.1.1.6)' \
--sms-to '79128887766'
```

Testing for Service mode:

```
# ./notification-to-sms.sh --plugin-mode 'service-mode' \ 
--notification-type 'PROBLEM' \
--host-displayname 'UPS01' --host-address '1.1.1.6' \
--service-desc 'UPS Input Voltage' \ 
--service-output 'SNMP CRITICAL - UPS Input Line Voltage *205* VAC' \
--sms-to '79128887766'
```

Icinga Director integration manual (in Russian):

[Развёртывание и настройка Icinga 2 на Debian 8.6. Часть 14. Настройка SMS оповещений в Icinga Director 1.3](https://blog.it-kb.ru/2017/09/15/deploy-and-configure-icinga-2-on-debian-8-part-14-icinga-director-1-3-and-sms-notifications-with-plugin-command-and-custom-shell-script/)
