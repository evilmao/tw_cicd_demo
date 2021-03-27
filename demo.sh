#!/bin/bash

docker_repo="https://download.docker.com/linux/centos/docker-ce.repo"
envoy_repo="https://getenvoy.io/linux/centos/tetrate-getenvoy.repo"

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
    yum install -y py-pip python3-dev libffi-dev openssl-dev gcc libc-dev rust cargo make
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


function step_by_step(){
    install_docker
    install_compose
    install_git
    install_envoy
    start_demo
}

step_by_step