#!/bin/sh
#set -x
#set -v

version="0.1.0"

usage="Usage: $0 command jailname [archive]
where:
  command: config|ezconfig|delete|restore|status|version
examples:
  my-jail-admin.sh version .................. print version
  my-jail-admin.sh status jail_01 ........... print status
  my-jail-admin.sh config jail_01 ........... print config
  my-jail-admin.sh delete jail_01 ........... delete jail
  my-jail-admin.sh restore jail_01 archive .. restore from archive"

case $1 in
    version)
	printf "$version\n"
	exit 0
	;;
    restore)
	archive="$3"
	;;
esac

if [ "$#" -lt 2 ]; then
    echo "$usage" >&2
    exit 1
fi

cmd="$1"
jailname="$2"

verbose="1"
logtofile="1"
logfile="/tmp/my-jail-admin.$jailname"
if [ "$verbose" = "1" ] && [ "$logtofile" = "1" ]; then
    printf "[Logging: $logfile]\n"
fi

confdir="/etc"
fstabdir="/etc/jail"
jaildir="/local/jails"
localconfdir="/usr/local/etc"
iddir="/var/run"
stampdir="/var/db/jail-stamps"

log() {
    my_date=`date "+%F %T"`
    if [ "$verbose" = "1" ]; then
	printf "${my_date}: ${jailname}: ${cmd}: ${message}"
    fi
    if [ "$logtofile" = "1" ]; then
	printf "${my_date}: ${jailname}: ${cmd}: ${message}" >> $logfile
    fi
}

jail-rcd() {
    if out=`/etc/rc.d/jail $1 $2 2>&1`; then
	message="[OK]  jail-rcd:\n$out\n"; log
    else
	message="[ERR] jail-rcd:\n$out\n"; log
	exit 1
    fi
}

ezjail-rcd() {
    if out=`/usr/local/etc/rc.d/ezjail $1 $2 2>&1`; then
	message="[OK]  ezjail-rcd:\n$out \n"; log
    else
	message="[ERR]  ezjail-rcd:\n$out \n"; log
	exit 1
    fi
}

ezjail-admin() {
    if out=`/usr/local/bin/ezjail-admin $1 $2 2>&1`; then
	message="[OK]  ezjail-admin:\n$out \n"; log
    else
	message="[ERR] ezjail-admin:\n$out \n"; log
	exit 1
    fi
}

ezjail-config() {
    if out=$(cat ${localconfdir}/ezjail/${jailname} 2>&1); then
	message="[OK]  \n${localconfdir}/ezjail/${jailname}\n${out}\n"; log
    else
	message="[ERR] \n${localconfdir}/ezjail/${jailname}\n${out}\n"; log
	exit 1
    fi
}

jail-config() {
    if out=$(sed -n "/$jailname {/,/}/p" ${confdir}/jail.conf 2>&1); then
	message="[OK]  \n${confdir}/jail.conf\n${out}\n"; log
    else
	message="[ERR] \n${confdir}/jail.conf\n${out}\n"; log
	exit 1
    fi
}

jail-status() {
    # PID file
    if [ -e "${iddir}/jail_${jailname}.id" ]; then
	message="[OK]  pid: ${iddir}/jail_${jailname}.id\n"; log
    else
	message="[WRN] pid: ${iddir}/jail_${jailname}.id does not exist\n"; log
    fi
    # Jail conf generated
    if [ -e "${iddir}/jail.${jailname}.conf" ]; then
	message="[OK]  conf: ${iddir}/jail.${jailname}.conf\n"; log
    else
	message="[WRN] conf: ${iddir}/jail.${jailname}.conf does not exist\n"; log
    fi
    # JAIL directory
    if [ -e "${jaildir}/${jailname}" ]; then
	message="[OK]  jail: ${jaildir}/${jailname}\n"; log
    else
	message="[WRN] jail: ${jaildir}/${jailname} does not exist\n"; log
    fi
    # FIRSRBOOT lockfile
    if [ -e "${stampdir}/${jailname}-firstboot" ]; then
	message="[OK]  lock: ${stampdir}/${jailname}-firstboot\n"; log
    else
	message="[WRN] lock: ${stampdir}/${jailname}-firstboot does not exist\n"; log
    fi
    # fstab in /etc
    if [ -e "/etc/fstab.${jailname}" ]; then
	message="[OK]  fstab: /etc/fstab.${jailname}\n"; log
    else
	message="[WRN] fstab: /etc/fstab.${jailname} does not exist\n"; log
    fi
    # fstab in fstabdir
    if [ -e "${fstabdir}/fstab.${jailname}" ]; then
	message="[OK]  fstab: ${fstabdir}/fstab.${jailname}\n"; log
    else
	message="[WRN] fstab: ${fstabdir}/fstab.${jailname} does not exist\n"; log
    fi
    # jail conf
    if [ -e "${confdir}/jail.conf" ]; then
	message="[OK]  conf: ${confdir}/jail.conf\n"; log
    else
	message="[WRN] conf: ${confdir}/jail.conf does not exist\n"; log
    fi
    # ezjail conf
    if [ -e "${localconfdir}/ezjail/${jailname}" ]; then
	message="[OK]  conf: ${localconfdir}/ezjail/${jailname}\n"; log
    else
	message="[WRN] conf: ${localconfdir}/ezjail/${jailname} does not exist\n"; log
    fi
    # status and list
    jail-rcd "status"
    # ezjail-admin "list"
}

jail-restore() {
    # test archive
    # TODO: get ezjail_archivedir from /usr/local/etc/ezjail.conf
    # restore JAIL
    if [ ! -e "${jaildir}/${jailname}" ]; then
	if ezjail-admin "restore" $archive; then
	    message="[OK]  jail: ${jailname} restored from ${archive}\n"; log
	else
	    message="[ERR] jail: ${jailname} not restored from ${archive}\n"; log
	    exit 1
	fi
    else
	message="[OK] jail: ${jaildir}/${jailname} exists\n"; log
    fi
    # touch FIRSRBOOT lockfile (no firstboot.sh when restored)
    if [ ! -e "${stampdir}/${jailname}-firstboot" ]; then
	if touch ${stampdir}/${jailname}-firstboot; then
	    message="[OK]  lock: ${stampdir}/${jailname}-firstboot created\n"; log
	else
    	    message="[ERR] lock: ${stampdir}/${jailname}-firstboot not created\n"; log
	    exit 1
	fi
    else
	message="[OK] lock: ${stampdir}/${jailname}-firstboot exists\n"; log
    fi
    # start JAIL
    if [ ! -e "${iddir}/jail_${jailname}.id" ]; then
        if jail-rcd start $jailname; then
	    message="[OK]  jail: ${jailname} started\n"; log
	else
	    message="[ERR] jail: ${jailname} not started\n"; log
	    exit 1
	fi
    else
	message="[OK] pid: ${iddir}/jail_${jailname}.id exists. Not started\n"; log
    fi
    # restart JAIL with ezjail
    # if [ -e "${iddir}/jail_${jailname}.id" ]; then
    #     if ezjail-rcd restart $jailname; then
    #         message="[OK]  jail: ${jailname} restarted with ezjail\n"; log
    #     else
    #         message="[ERR] jail: ${jailname} not restarted with ezjail\n"; log
    #         exit 1
    #     fi
    # else
    #     message="[OK] pid: ${iddir}/jail_${jailname}.id does not exist\n"; log
    # fi
}

jail-delete() {
    # stop JAIL
    if [ -e "${iddir}/jail_${jailname}.id" ]; then
        if jail-rcd stop $jailname; then
	    message="[OK]  jail: ${jailname} stopped\n"; log
	else
	    message="[ERR] jail: ${jailname} not stopped\n"; log
	    exit 1
	fi
    else
	message="[OK] pid: ${iddir}/jail_${jailname}.id does not exist\n"; log
    fi
    # delete JAIL
    if [ -e "${jaildir}/${jailname}" ]; then
	if ezjail-admin "delete -wf" $jailname; then
	    message="[OK]  jail: ${jailname} deleted\n"; log
	else
	    message="[ERR] jail: ${jailname} not deleted\n"; log
	    exit 1
	fi
    else
	message="[OK] jail: ${jaildir}/${jailname} does not exist\n"; log
    fi
    # delete FIRSRBOOT lockfile
    if [ -e "${stampdir}/${jailname}-firstboot" ]; then
	if rm ${stampdir}/${jailname}-firstboot; then
	    message="[OK]  lock: ${stampdir}/${jailname}-firstboot removed\n"; log
	else
	    message="[ERR] lock: ${stampdir}/${jailname}-firstboot not removed\n"; log
	    exit 1
	fi
    else
	message="[OK] lock: ${stampdir}/${jailname}-firstboot does not exist\n"; log
    fi
}

case $cmd in
    config)
	jail-config
        ;;
    ezconfig)
	ezjail-config
        ;;
    delete)
	jail-delete
        ;;
    restore)
	jail-restore
        ;;
    status)
	jail-status
        ;;
    *)
	message="[ERR] Unknown command\n"; log
	echo "$usage" >&2
	exit 1
	;;
esac

exit 0

# EOF
