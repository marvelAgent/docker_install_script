RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

#Check system
check_sys(){
    local checkType=${1}
    local value=${2}

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ]; then
            return 0
        else
            return 1
        fi
    fi
}

log(){
    if   [ "${1}" == "Warning" ]; then
        echo -e "[${YELLOW}${1}${PLAIN}] ${2}"
    elif [ "${1}" == "Error" ]; then
        echo -e "[${RED}${1}${PLAIN}] ${2}"
    elif [ "${1}" == "Info" ]; then
        echo -e "[${GREEN}${1}${PLAIN}] ${2}"
    else
        echo -e "[${1}] ${2}"
    fi
}

rootneed(){
    if [[ ${EUID} -ne 0 ]]; then
       log "Error" "This script must be run as root"
       exit 1
    fi
}

centos_local_repo_install(){
    if [[ -d /etc/yum.repos.d.bak ]]; then
	log "Error" "please delete directory /etc/yum.repos.d.bak"
	exit 1
    fi
    mv /etc/yum.repos.d/ /etc/yum.repos.d.bak
    mkdir /etc/yum.repos.d
    touch /etc/yum.repos.d/local.repo
    echo "[BASE]" > /etc/yum.repos.d/local.repo
    echo "name=base" >> /etc/yum.repos.d/local.repo
    echo "baseurl=file://${cur_dir}/repo/centosRepo" >> /etc/yum.repos.d/local.repo
    echo "enabled=1" >> /etc/yum.repos.d/local.repo
    echo "gpgcheck=0" >> /etc/yum.repos.d/local.repo
    yum clean all
    yum makecache
}

centos_local_repo_remove(){
    rm -rf /etc/yum.repos.d
    mv /etc/yum.repos.d.bak /etc/yum.repos.d
    yum clean all
#    yum makecache
}

ubuntu_local_repo_install(){
    if [[ -f /etc/apt/sources.list.bak ]]; then
	log "Error" "please delete file /etc/apt/sources.list.bak"
	exit 1
    fi
    mv /etc/apt/sources.list /etc/apt/sources.list.bak
    touch /etc/apt/sources.list
    echo deb file://${cur_dir}/repo cache/ > /etc/apt/sources.list
    sudo apt-get update
}

ubuntu_local_repo_remove(){
    rm -f /etc/apt/sources.list
    mv /etc/apt/sources.list.bak /etc/apt/sources.list
#    sudo apt-get update
}

closeFirewareAndSelinux(){
    if check_sys packageManager yum; then
    	systemctl stop firewalld
        systemctl disable firewalld
        setenforce 0
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    elif check_sys packageManager apt; then
    	ufw disable
#        apt-get -y remove iptables
    fi
}

ubuntuInstallSSH(){
    apt-get -y install openssh-server
    systemctl start sshd
    systemctl enable sshd
}
