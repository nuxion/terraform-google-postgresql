#!/bin/bash
set -o nounset
set -o errexit
export DEBIAN_FRONTEND=noninteractive
CHECK_EVERY=8
LOG_FILE=/var/log/startup.log
PG_OPT=/opt/services/postgres14
PG_ETC=/etc/postgresql/14/main
PG_LOCK=${PG_OPT}/.installed.lock
PG_CONF=${PG_OPT}/config.yaml

CS_VERSION=0.6.0
# CS_VERSION=main 

exec 3>&1 1>>${LOG_FILE} 2>&1

_log() {
   echo "$(date): $@" | tee /dev/fd/3
}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

create_user(){
    if id -u "$1" >/dev/null 2>&1; then
        _log "user ${1} created"
    else
        _log 'user ${1} missing'
        useradd -g google-sudoers -m $1
    fi
}


update_conf(){
    gsutil cp $1/db/${HOSTNAME}/config.yaml /tmp/config.yaml
    if ! diff /tmp/config.yaml $PG_CONF; then
        _log "Changes detected for config.yaml"
        mv /tmp/config.yaml $PG_CONF
        gomplate -d "config=${PG_CONF}" -f ${PG_OPT}/templates/postgresql.tpl.conf -o ${PG_ETC}/postgresql.conf
        gomplate -d "config=${PG_CONF}" -f ${PG_OPT}/templates/pg_hba.tpl.conf -o ${PG_ETC}/pg_hba.conf
        systemctl stop postgresql
        systemctl start postgresql
    else
        _log "No Changes for config.yaml"
        rm /tmp/config.yaml
    fi
    
}

install_psql(){
    cscli -i postgresql14
    systemctl stop postgresql
    systemctl disable postgresql
    mkdir -p ${PG_OPT}/templates
    mkdir -p ${PG_OPT}/backups
    mkdir -p ${PG_OPT}/scripts
    touch ${PG_LOCK}
    cp /opt/cloudscripts-${CS_VERSION}/scripts/templates/pg14/* ${PG_OPT}/templates
    cp /opt/cloudscripts-${CS_VERSION}/scripts/db/pg_* ${PG_OPT}/scripts
    update_conf $1
    }

# https://bugs.launchpad.net/ubuntu/+source/man-db/+bug/1858777
if [ ! -f "/opt/apt-update.lock" ];
then
    _log "Starting apt-update"
    touch /var/lib/man-db/auto-update
    apt-get update -y | tee /dev/fd/3
    touch /opt/apt-update.lock
    _log "apt-update finished"
fi

if ! command_exists "cscli" &> /dev/null
then
    curl -Ls https://raw.githubusercontent.com/nuxion/cloudscripts/${CS_VERSION}/install.sh | bash
fi

if ! command_exists "jq" &> /dev/null
then
    apt-get install -y jq
fi

if ! command_exists "git" &> /dev/null
then
    apt-get install -y git
fi

if ! command_exists "gomplate" &> /dev/null
then
    cscli -i gomplate
fi

META=`curl -s "http://metadata.google.internal/computeMetadata/v1/instance/?recursive=true" -H "Metadata-Flavor: Google"`
BUCKET=`echo $META | jq .attributes.bucket | tr -d '"'`
# IPV4=`echo ${META} | jq ".networkInterfaces[0].ip" | tr -d '"'`

if [ ! -f "${PG_LOCK}" ];
then
    install_psql "${BUCKET}"
else
    update_conf "${BUCKET}"
fi
