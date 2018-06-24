#!/bin/sh
WHERE='other'
# install ansible
if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    DISTRO='centos'
elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
    DISTRO='ubuntu'
fi

echo "[STARTing Install Ansible]**********************************************************"
case $DISTRO in
    centos)
        yum -q install -y epel-release
        yum -q install -y gcc python-devel python-pip libffi-devel openssl-devel
        ;;
    ubuntu)
        apt-get -q install -y python-dev python-pip libssl-dev libffi-dev
        ;;
    *)
        echo "This distro id is not recognized"
        exit 2
esac

pip -q install --upgrade pip
pip -q install ansible

echo "[START install docker]**********************************************************"
# check ansible can run success and install docker
ret=$(ansible --version)
if [ $? -eq 0 ]
then
    path=$(cd `dirname $0`; pwd)
    echo "Using Ansible to install docker"
    ansible-playbook $path/yml_files/docker_install.yml -e WHERE=$WHERE
else
    echo "ansible is not install"
fi

service docker start
systemctl enable docker



path=$(cd `dirname $0`; pwd)
ansible-playbook -e path=$path $path/docker_image_import.yml
