#!/usr/bin/env bash
readonly cb_name=$1
readonly role=$2
readonly scope=$3
hostname=`hostname`
barman_dir="${BARMAN_CONF_DIR:-/u01/barman/barman.d}"
barman_primary="${BARMAN_PRIMARY:-10.255.65.17}"
barman_user="${BARMAN_USER:-barman}"
barman_script_path="${BARMAN_SCRIPT_PATH:=/var/lib/barman/enable-config.sh}"
function usage() {
    echo "Usage: $0 <on_start|on_role_change> <role> <scope>";
    exit 1;
}

case $cb_name in
    on_start|on_role_change )
        if [ $role == 'master' ]
        then
            echo "Role change to $role"
            ssh $barman_user@$barman_primary "$barman_script_path $hostname $barman_dir"
        fi
    ;;
    * )
    usage
    ;;
esac
