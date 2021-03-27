#!/bin/bash

docker_repo="https://download.docker.com/linux/centos/docker-ce.repo"
envoy_repo="https://getenvoy.io/linux/centos/tetrate-getenvoy.repo"


#  root option
function prepare_check() {
  isRoot=`id -u -n | grep root | wc -l`
  
  if [ "x$isRoot" != "x1" ]; then
      echo -e "[\033[31m ERROR \033[0m] Please use root to execute the installation script (请用 root 用户执行安装脚本)"
      exit 1
  fi

}

function install_soft() {
    if command -v dnf > /dev/null; then
      if [ "$1" == "python3" ]; then
        dnf -q -y install python3
        ln -s /usr/bin/python3 /usr/bin/python
      else
        dnf -q -y install $1
      fi

    elif command -v yum > /dev/null; then
      yum -q -y install $1

    elif command -v apt > /dev/null; then
      apt-get -qqy install $1

    elif command -v zypper > /dev/null; then
      zypper -q -n install $1

    elif command -v apk > /dev/null; then
      apk add -q $1

    else
      echo -e "[\033[31m ERROR \033[0m] Please install it first (请先安装) $1 "
      exit 1
    fi
}


function prepare_install() {

  for i in curl py-pip python3-dev libffi-dev openssl-dev gcc libc-dev rust cargo make yum; do
    command -v $i &>/dev/null || install_soft $i
  done
}


function install_docker(){
    echo "安装依赖包: "
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo $docker_repo
    sudo yum-config-manager --enable docker-ce-nightly
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo yum install -y docker-ce-19.03 docker-ce-cli-19.03 containerd.io
    echo "安装完成,启动docker"
    sudo systemctl start docker

}

function install_compose(){
    echo "安装docker_compose依赖"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo "检查docker-compose 版本:"
    docker-compose --version
}


function install_git(){
    echo "will install git..."
    sudo yum install -y git >/dev/null
    echo  "check git version:"
    git --version
}


function install_envoy(){
    echo "will install envoy..."
    sudo yum-config-manager --add-repo $envoy_repo
    sudo yum install -y getenvoy-envoy
    echo "check envoy version:"
    envoy --version
}


function start_demo(){
    echo "启动程序:"
    cd demo
    docker-compose up --build -d 
    echo "启动成功!"    

}


function main(){
    install_soft
    prepare_install
    install_docker
    install_compose
    install_git
    install_envoy
    start_demo
}

main