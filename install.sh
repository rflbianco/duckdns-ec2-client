#!/bin/bash

DEFAULT_BRANCH="master"

usage() {
    echo "Usage: $0 [--branch BRANCH_NAME]"
    echo ""
    echo "Options:"
    echo "    --help                    Shows this usage and exits."
    echo ""
    echo "    --branch BRANCH_NAME      Allows selecting which branch of git repoository to install from. Default: ${DEFAULT_BRANCH}"
}

checkDependencies() {
    echo "Checking runtime dependency: unzip..."
    
    if [ -z "$(which unzip)" ]; then
        echo "fail"
        exit 1
    else
        echo "ok"
    fi
}

setToken() {
    echo "Set Token on installation is not supported yet. Please, edit settings in /etc/duckdns/duckdns.conf"
}

setDomains() {
    echo "Set Domains on installation is not supported yet. Please, edit settings in /etc/duckdns/duckdns.conf"
}

setTime() {
    echo "Set update Time on installation is not supported yet. Please, edit settings in /etc/duckdns/duckdns.conf"
}

checkDependencies

while [ -n "$1" ]; do
    case $1 in
        '--branch')
            _branch="$2"
            if [ -z "$_branch" ]; then
                echo "Bad usage. Param '--branch' requires a value. See usage."
                usage
                exit 1
            fi
            shift
            ;;
        '--help')
            usage
            exit
            ;;
        *)
            ;;
    esac
    shift
done

branch=${_branch:-$DEFAULT_BRANCH}
user=duckdns

url="https://github.com/rflbianco/duckdns-ec2-client/archive/${branch}.zip"
file_name='duckdns-ec2-client'

echo "#########################################################################"
echo "Installing DuckDNS client from '${branch}'..."
echo ""


echo "Adding user ${user}..."
getent passwd $user > /dev/null
if [ $? -ne 0 ]; then 
    adduser --disabled-login --gecos 'Duckdns' ${user}
    passwd -d ${user}
fi


echo "Downloading files..."
cd /tmp \
   && wget $url -O "./${file_name}.zip"\
   && unzip "./${file_name}.zip"

if [ $? -gt 0 ]; then
    echo "Error while downloading from Github. Probable cause: branch '${branch}' does not exists. See 'stdout' for more information."
    exit 1
fi

echo "Coping files to your system..."
cd "/tmp/${file_name}-${branch}"
sudo cp bin/duckdnsd /usr/bin/duckdnsd

sudo mkdir /etc/duckdns
sudo cp etc/duckdns.conf.example /etc/duckdns/duckdns.conf
setToken
setDomains
setTime

sudo cp init.d/duckdns /etc/init.d/duckdns

sudo ln -s /etc/init.d/duckdns /etc/rc2.d/S20duckdns
sudo ln -s /etc/init.d/duckdns /etc/rc3.d/S20duckdns
sudo ln -s /etc/init.d/duckdns /etc/rc4.d/S20duckdns
sudo ln -s /etc/init.d/duckdns /etc/rc5.d/S20duckdns

echo "DuckDNS client installed successfully"

