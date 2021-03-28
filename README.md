# tw_cicd_demo
demo cicd by github + travis


## 一键启动脚本

首次安装执行脚本: `sudo bash requick_start.sh`


## 程序说明

1. 简单的web应用
2. 部署方案使用: docker + docker-compose 部署方案
3. 应用使用 service mesh 架构模型, 使用开源envoy组件即sidecar方式进行部署, 实现简单的流量代理,负载均衡,断融,服务发现 等功能, 
4. docker-compose 用来重启, 暂停
