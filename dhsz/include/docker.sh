if check_sys packageManager yum; then
    centos_local_repo_install
    yum -y install docker
    centos_local_repo_remove
    systemctl start docker
    systemctl enable docker
elif check_sys packageManager apt; then
    ubuntu_local_repo_install
    ubuntuInstallSSH
    apt-get -y install docker.io
    ubuntu_local_repo_remove
    systemctl start docker
    systemctl enable docker
fi
