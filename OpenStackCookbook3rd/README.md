#《OpenStack云计算实战手册（第3版）》
=============================

9787115472427 201802

[源码](https://github.com/OpenStackCookbook/OpenStackCookbook)

[EPUB](https://www.epubit.com/book/detail/21053;jsessionid=F82372F9415390B2CBCD6D9E9FC12A20)

[OpenStack Releases](https://releases.openstack.org/)

[Ubuntu Cloud Archive](https://wiki.ubuntu.com/OpenStack/CloudArchive)

[OpenStack Installation Guide for Ubuntu](https://docs.openstack.org/mitaka/zh_CN/install-guide-ubuntu/)


# Prepare
=============================

## Softs
```
Ubuntu 14.04.5 LTS
VMware® Workstation 12 Pro
```

## Nodes

HostName    |IP   |Openstack Services
- | - | - 
controller  | 200 |keystone,ntp,mysql

```
备注：
1.每个节点有两个IP地址。前端IP地址192.168.100.X和后端IP地址172.16.0.X(包括MariaDB服务器的地址)。
eth1 192.168.100.X
eth2 172.16.0.X
2.每个节点执行下述命令初始化
$ sudo sh common.sh nodeinit
```

# Contents
=============================

## ch01 Keystone - OpenStack身份认证服务
```
ssh controller
$ sudo sh common.sh mariadb
$ sudo sh keystone.sh [install|ssl|account]
```

