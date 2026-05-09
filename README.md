# docker

## 执行顺序

先启动 caddy 创建docker 网络，将子域名代理到各个服务上

启动 manager 方便管理监控 docker 容器

启动 tool 提供 jupyter 等工具

启动 service 提供 redis mysql 等基础服务

最后启动 server 提供具体的 api 服务

## 端口分配

对外只暴露 caddy 的 80 443 端口
其余端口通过 caddy 子域名反向代理

### caddy

80 443

### manager

3000 - 3999

- 3000 portainer https
- 3001 portainer http
- 3002 dozzle

### tool

4000 - 4999

- 4000 speedtest
- 4001 speedtest
- 4002 jupyter notebook

### service

5000 - 5999，直接对外暴露

- 5000 redis
- 5001 mysql
- 5002 adminer
- 5003 rabbitmq
- 5004 rabbitmq management

### server

6000 - 6999

## 模块使用

### manager

lazydocker 管理 docker

dozzle 查看日志

portainer 管理 docker，专注容器管理
komodo 管理 docker，配置稍微复杂，可以作为 portainer 替代，更强大的工具
dockge 管理 docker，占用太多内存，放弃使用

### tool

jupyter 在线 jupyter notebook

speedtest 测速

### service

redis

mysql
adminer 快速管理数据库

rabbitmq

## server

具体服务
