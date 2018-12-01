#!/bin/bash
###########################################################
# keystone.sh
# Chapter 1 KEYSTONE (Keystone--OpenStack身份认证服务)
###########################################################

# Source in common env vars
BASEDIR=$(cd `dirname $0`; pwd)
. $BASEDIR/common.sh

KEYSTONE_CONF=/etc/keystone/keystone.conf

#=====================
# 1.2 安装OpenStack身份认证服务
#=====================
keystone_install(){
	echo "---------- keystone_install ----------"
	
	# Uninstall
	#sudo rm -rf /var/lib/keystone/
	#sudo apt-get remove keystone --purge
	
	# Install
	echo ">>>>> Install"
	sudo apt-get -y install ntp keystone python-keyring
	
	sudo keystone --version
	if [ ! -d "${BACKUP_DIR}/keystone" ]; then
		sudo cp -r /etc/keystone ${BACKUP_DIR}
	fi

	# Create database
	echo ">>>>> Create database"
	#MYSQL_ROOT_PASS=openstack
	#MYSQL_KEYSTONE_PASS=openstack
	mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE IF NOT EXISTS keystone;'
	mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$MYSQL_KEYSTONE_PASS';"
	mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$MYSQL_KEYSTONE_PASS';"

	# Config Files
	echo ">>>>> Config Files"
	sudo sed -i "s#^connection.*#connection = mysql://keystone:${MYSQL_KEYSTONE_PASS}@${MYSQL_HOST}/keystone#" ${KEYSTONE_CONF}
	sudo sed -i 's/^#admin_token.*/admin_token = ADMIN/' ${KEYSTONE_CONF}
	sudo sed -i 's,^#log_dir.*,log_dir = /var/log/keystone,' ${KEYSTONE_CONF}

	#--在某行下面新增行
	#sudo sed -i '/^use_syslog = .*/d' ${KEYSTONE_CONF}
	#sudo sed -i '/^Distribution = .*/a\\use_syslog = True' ${KEYSTONE_CONF}
	#sudo sed -i '/^syslog_log_facility = .*/d' ${KEYSTONE_CONF}
	#sudo sed -i '/^use_syslog = .*/a\\syslog_log_facility = LOG_LOCAL0' ${KEYSTONE_CONF}

	# 重启keystone服务
	echo ">>>>> Restart service"
	sudo stop keystone
	sudo start keystone
	
	# 为keystone数据库填充必需的数据表
	echo ">>>>> db_sync"
	sudo keystone-manage db_sync
}

#=====================
# 1.3 为SSL通信配置OpenStack身份认证
# 所有Keystone的通信都将通过HTTPS加密。
#=====================
keystone_ssl(){
	echo "---------- keystone_ssl ----------"
	
	# 创建自签名证书
	sudo apt-get -y install python-keystoneclient

	#rm -rf /etc/keystone/ssl
	sudo keystone-manage ssl_setup --keystone-user keystone --keystone-group keystone

	# 把证书放置在一个可访问的地方，方便在其他服务里引用
	sudo cp /etc/keystone/ssl/certs/ca.pem /etc/ssl/certs/ca.pem
	sudo c_rehash /etc/ssl/certs/ca.pem

	# 配置keystone
	sudo sed -ri "/\[ssl\]/,/^#*enable *=/{s,^#*enable *=.*,enable=True,}" ${KEYSTONE_CONF}
	sudo sed -ri "/\[ssl\]/,/^#*certfile *=/{s,^#*certfile *=.*,certfile=/etc/keystone/ssl/certs/keystone.pem,}" ${KEYSTONE_CONF}
	sudo sed -ri "/\[ssl\]/,/#*keyfile *=/{s,^#*keyfile *=.*,keyfile=/etc/keystone/ssl/private/keystonekey.pem,}" ${KEYSTONE_CONF}
	sudo sed -ri "/\[ssl\]/,/^#*ca_certs *=/{s,^#*ca_certs *=.*,ca_certs=/etc/keystone/ssl/certs/ca.pem,}" ${KEYSTONE_CONF}
	sudo sed -ri "/\[ssl\]/,/^#*cert_subject *=/{s,^#*cert_subject *=.*,cert_subject=/C=US/ST=Unset/L=Unset/O=Unset/CN=${CONTROLLER_HOST},}" ${KEYSTONE_CONF}
	sudo sed -ri "/\[ssl\]/,/^#*ca_key *=/{s,^#*ca_key *=.*,ca_key=/etc/keystone/ssl/private/cakey.pem,}" ${KEYSTONE_CONF}

	# 重启keystone服务
	echo ">>>>> Restart service"
	sudo stop keystone
	sudo start keystone
}

#=====================
# 1.4 在Keystone里创建租户
#=====================
create_account(){
	echo "---------- create_account ----------"
	# 为了能以管理者权限访问OpenStack环境，请确保已经正确设置环境
	export OS_TENANT_NAME=cookbook
	export OS_USERNAME=admin
	export OS_PASSWORD=openstack
	export OS_AUTH_URL=https://192.168.100.200:5000/v2.0/
	export OS_NO_CACHE=1
	export OS_KEY=/vagrant/cakey.pem
	export OS_CACERT=/vagrant/ca.pem
	
	# 创建租户
	keystone tenant-create --name cookbook --description "Default Cookbook Tenant" --enabled true
	
	keystone tenant-list
}

#================================================
# main
#================================================
if [ "$FILENAME" = "keystone.sh" ] ; then
	echo "::EXEC:: $FILENAME"
	if [ "$1" = "install" ] ; then
		shift
		keystone_install;
	elif [ "$1" = "ssl" ]; then
		shift
		keystone_ssl;
	elif [ "$1" = "account" ]; then
		shift
		create_account;
	else
		echo "run default for $FILENAME"
	fi
fi
