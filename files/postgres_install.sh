#!/bin/bash
set -o nounset
set -o errexit
export DEBIAN_FRONTEND=noninteractive
CHECK_EVERY=8
LOG_FILE=/var/log/startup.log

exec 3>&1 1>>${LOG_FILE} 2>&1

_log() {
   echo "$(date): $@" | tee /dev/fd/3
}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

create_user(){
    if id -u "$user" >/dev/null 2>&1; then
        echo 'user exists'
    else
        echo 'user missing'
        useradd -g google-sudoers -m op
    fi
}

install_psql(){
    cscli -i postgresql14
    systemctl stop postgresql
    systemctl disable postgresql
}

# https://bugs.launchpad.net/ubuntu/+source/man-db/+bug/1858777
if [ ! -f "/opt/apt-update.lock" ];
then
    _log "Starting apt-update"
    touch /var/lib/man-db/auto-update
    apt-get update -y | tee /dev/fd/3
    touch /opt/apt-update.lock
    _log "apt-update Finished"
fi

if ! command_exists "cscli" &> /dev/null
then
    curl -Ls https://raw.githubusercontent.com/nuxion/cloudscripts/0.5.0/install.sh | bash
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
PROJECT=`echo $META | jq .attributes.project | tr -d '"'`
VERSION=`echo $META | jq .attributes.version | tr -d '"'`
BUCKET=`echo $META | jq .attributes.bucket | tr -d '"'`
IPV4=`echo ${META} | jq ".networkInterfaces[0].ip" | tr -d '"'`


#wait_kube(){
#    running=`kubectl get pods -n kube-system | grep Running | wc -l`
#    while [ $running -lt 3 ]
#    do
#        _log "Waiting for kubernetes to be readdy..."
#        running=`kubectl get pods -n kube-system | grep Running | wc -l`
#        sleep $CHECK_EVERY
#    done
#    
#}
