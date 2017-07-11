#!/bin/bash
#author:nuaags
#All rights reserved; those responsible for unauthorized reproduction will be prosecuted.
#readme:this file install docker/hadoop/spark/zeppelin
#       need root
#	support centos/redhat/debian/ubuntu

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cur_dir=`pwd`

include(){
    local include=${1}
    if [[ -s ${cur_dir}/include/${include}.sh ]];then
        . ${cur_dir}/include/${include}.sh
    else
        echo "Error:${cur_dir}/include/${include}.sh not found, shell can not be executed."
        exit 1
    fi
}

#lamp main process
lamp(){
    include public
    rootneed
    closeFirewareAndSelinux
    include docker
}

#Run it
lamp 2>&1 | tee ${cur_dir}/lamp.log

