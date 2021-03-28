#!/bin/bash

SORF_DOWNLOAD_DIR=/tmp
docker_repo="https://download.docker.com/linux/centos/docker-ce.repo"
envoy_repo="https://getenvoy.io/linux/centos/tetrate-getenvoy.repo"
docker_version="19.03.1"
docker_link="https://download.docker.com/linux/static/stable/x86_64/docker-$(docker_version).tgz"


#  root option
function prepare_check() {
  isRoot=`id -u -n | grep root | wc -l`
  
  if [ "x$isRoot" != "x1" ]; then
      echo -e "[\033[31m ERROR \033[0m] Please use root to execute the installation script (请用 root 用户执行安装脚本)"
      exit 1
  fi

}


function install_choice() {
    if command -v dnf > /dev/null; then
      if [ "$1" == "python" ]; then
        dnf -q -y install python3
        ln -s /usr/bin/python3 /usr/bin/python
      elif [ "$1" == "git" ]; then
         dnf -q -y install git-all 
      else
        dnf -q -y install $1
      fi

    elif command -v yum > /dev/null; then
      yum -q -y install $1

    elif command -v apt > /dev/null; then
       if [ "$1" == "git" ]; then
         dnf -q -y install git-all 
      else
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


function prepare_install(){
    echo "1. 其他组件安装: "
    for i in wget curl python git;do
        command -v $i &>/dev/null || install_choice $i
    done

}


function install_soft(){
    cd $SORF_DOWNLOAD_DIR

    for i in docker docker docker-compose envoy;do
        if [ "$i" == "docker" ];then
            command -v $i &>/dev/null || install_docker 
        elif [ "$i" == "docker-compose" ];then
            command -v $i &>/dev/null || install_compose
        elif [ "$i" == "envoy" ];then
            command -v $i &>/dev/null || install_envoy
        fi
    done
    

}


function install_docker(){
    echo "1. 安装docker: "
    cd $SORF_DOWNLOAD_DIR
    wget -qO docker-$docker_version.tgz $docker_link || {
        rm -rf /$SORF_DOWNLOAD_DIR/docker-$docker_version.tgz
        echo -e "[\033[31m ERROR \033[0m] Failed to download docker(下载 docker 失败, 请检查网络是否正常或尝试重新执行脚本)"
        exit 1
    }

    tar xzvf docker-$docker_version.tgz && sudo cp docker/* /usr/bin/ 
    # 切换 /tmp目录
    cd ../ 
    echo "install docker success, will start..."
    sudo dockerd & 
    echo "check docker version:"
    docker --version
   
    # sudo yum install -y yum-utils
    # sudo yum-config-manager --add-repo $docker_repo
    # sudo yum-config-manager --enable docker-ce-nightly
    # sudo yum install -y docker-ce docker-ce-cli containerd.io
    # sudo yum install -y docker-ce-19.03 docker-ce-cli-19.03 containerd.io
    # sudo systemctl start docker

}

function install_compose(){
    echo "2. 安装docker_compose:"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo "check docker-compose version:"
    docker-compose --version
}


function install_envoy(){
    echo "4. 安装envoy:"
    curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
    echo "check envoy version:"
    getenvoy run standard:1.17.1 -- --version
}


function install_demo(){
   echo "4. 下载demo:"
   mkdir -p /project 
   git clone https://github.com/evilmao/tw_cicd_demo.git
   cd /project/tw_cicd_demo

}

function start(){
    echo "5.启动程序:"
    cd demo
    docker-compose up --build -d 
    echo "启动成功!"    

}


function main(){
    prepare_check
    prepare_install
    install_soft
    install_demo
    start
}

main