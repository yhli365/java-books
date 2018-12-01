#!/bin/bash
###########################################################
# common.sh
# scripts used by the OpenStack Cloud Computing Cookbook, 3rd Edition, 2014
# Scripts for Juno!
#
# Sets up common bits used in each build script.
#
###########################################################

export FILENAME=$(basename $0)
BASEDIR=$(cd `dirname $0`; pwd)

# Useful if you have a cache on your network. Adjust to suit.
# echo "Acquire::http { Proxy \"http://192.168.1.20:3142\"; };" > /etc/apt/apt.conf.d/01squid

export DEBIAN_FRONTEND=noninteractive
echo "set grub-pc/install_devices /dev/sda" | sudo debconf-communicate

ETH1_IP=$(ifconfig eth1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}') #192.168.100.X
ETH2_IP=$(ifconfig eth2 | awk '/inet addr/ {split ($2,A,":"); print A[2]}') #172.16.0.X

PUBLIC_IP=${ETH1_IP}
INNER_IP=${ETH2_IP}

#export CONTROLLER_HOST=172.16.0.200
#Dynamically determine first three octets if user specifies alternative IP ranges.  Fourth octet still hardcoded
export CONTROLLER_HOST=$(echo $INNER_IP | sed 's/\.[0-9]*$/.200/')
export GLANCE_HOST=${CONTROLLER_HOST}
export KEYSTONE_ADMIN_ENDPOINT=$(echo $PUBLIC_IP | sed 's/\.[0-9]*$/.200/')
export KEYSTONE_ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
export CONTROLLER_EXTERNAL_HOST=${KEYSTONE_ADMIN_ENDPOINT}
export SERVICE_TENANT_NAME=service
export SERVICE_PASS=openstack
export ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
export SERVICE_TOKEN=ADMIN
export SERVICE_ENDPOINT=http://${KEYSTONE_ADMIN_ENDPOINT}:35357/v2.0
export MONGO_KEY=MongoFoo
export OS_CACERT=$BASEDIR/ca.pem
export OS_KEY=$BASEDIR/cakey.pem

export MYSQL_HOST=${CONTROLLER_HOST}
export MYSQL_ROOT_PASS=openstack
export MYSQL_DB_PASS=openstack
export MYSQL_KEYSTONE_PASS=${MYSQL_DB_PASS}
export MYSQL_NEUTRON_PASS=${MYSQL_DB_PASS}

export BACKUP_DIR=/opt/openstack
sudo mkdir -p ${BACKUP_DIR}

config_show(){
	echo "---------- config_show ----------"
	echo "BASEDIR: $BASEDIR"
	echo "PUBLIC_IP: $PUBLIC_IP"
	echo "INNER_IP: $INNER_IP"
}

config_repo(){
	echo "---------- config_repo ----------"
	sudo apt-get update
	sudo apt-get install -y software-properties-common ubuntu-cloud-keyring
	sudo add-apt-repository -y cloud-archive:juno
	sudo apt-get update && sudo apt-get upgrade -y
}

config_hosts(){
	echo "---------- config_hosts ----------"
	FLAG=$(egrep CookbookHosts /etc/hosts | awk '{print $2}')
	#echo $FLAG
	if [ -z "$FLAG" ] ; then
		# Add host entries
		echo "
# CookbookHosts
192.168.100.200	controller.book controller
192.168.100.201	network.book network
192.168.100.202	compute-01.book compute-01
192.168.100.203	compute-02.book compute-02
192.168.100.210	swift.book swift
192.168.100.212	swift2.book swift2
192.168.100.211	cinder.book cinder" | sudo tee -a /etc/hosts
	fi
}

config_alias(){
	echo "---------- config_alias ----------"
	# Aliases for insecure SSL
	alias nova='nova --insecure'
	alias keystone='keystone --insecure'
	alias neutron='neutron --insecure'
	alias glance='glance --insecure'
	alias cinder='cinder --insecure'
}

node_init(){
	config_repo;
}

#=====================
# 安装依赖包: MySQL
#=====================
mariadb_install(){
	echo "---------- mariadb_install ----------"
	#export LANG=C

	# MySQL
	#export MYSQL_HOST=${ETH1_IP}
	#export MYSQL_ROOT_PASS=openstack
	#export MYSQL_DB_PASS=openstack

	# debian apt mysql无密码安装
	echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
	echo "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
	echo "mysql-server-5.5 mysql-server/root_password seen true" | sudo debconf-set-selections
	echo "mysql-server-5.5 mysql-server/root_password_again seen true" | sudo debconf-set-selections

	sudo apt-get -y install mariadb-server python-mysqldb

	sudo sed -i "s/^bind\-address.*/bind-address = 0.0.0.0/g" /etc/mysql/my.cnf
	sudo sed -i "s/^#max_connections.*/max_connections = 512/g" /etc/mysql/my.cnf

	# Skip Name Resolve
	echo "[mysqld]
	skip-name-resolve" | sudo tee /etc/mysql/conf.d/skip-name-resolve.cnf

	# UTF-8 Stuff
	echo "[mysqld]
	collation-server = utf8_general_ci
	init-connect='SET NAMES utf8'
	character-set-server = utf8" | sudo tee /etc/mysql/conf.d/01-utf8.cnf

	sudo service mysql restart

	# Ensure root can do its job
	mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"localhost\" IDENTIFIED BY \"${MYSQL_ROOT_PASS}\" WITH GRANT OPTION;"
	mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"${MYSQL_HOST}\" IDENTIFIED BY \"${MYSQL_ROOT_PASS}\" WITH GRANT OPTION;"
	mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"%\" IDENTIFIED BY \"${MYSQL_ROOT_PASS}\" WITH GRANT OPTION;"

	mysqladmin -uroot -p${MYSQL_ROOT_PASS} flush-privileges
}

config_test(){
	echo "---------- config_test ----------"
	sudo service ssh status
}

#================================================
# main
#================================================
if [ "$FILENAME" = "common.sh" ] ; then
	echo "::EXEC:: $FILENAME"
	if [ "$1" = "test" ] ; then
		shift
		config_test;
	elif [ "$1" = "repo" ] ; then
		shift
		config_repo;
	elif [ "$1" = "hosts" ]; then
		shift
		config_hosts;
	elif [ "$1" = "alias" ]; then
		shift
		config_alias;
	elif [ "$1" = "mariadb" ]; then
		shift
		mariadb_install;
	else
		echo "run default for $FILENAME"
		config_show;
		#config_repo;
		config_hosts;
		#config_alias;
	fi
fi
