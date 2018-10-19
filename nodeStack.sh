#!/bin/bash
# install and configure node.js server
# likequincy@outlook.com 2018-10-18

printf "
##############################################################################
#       nodeStack auto install script for aliyun ECS with CentOS 7           #
#       For more information please visit http://nodeStack.code4ever.cn      #
##############################################################################
"
# 检查用户权限
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

function echo_success()
{
    str=$1
    color="32"
		str="\n\033[${color}m>>>>>>> ${str}\033[0m"
    echo -e "${str}"
}
function echo_error()
{
    str=$1
    color="31"
		str="\n\033[${color}m>>>>>>> ${str}\033[0m"
    echo -e "${str}"
}
function echo_warning()
{
    str=$1
    color="33"
		str="\n\033[${color}m>>>>>>> ${str}\033[0m"
    echo -e "${str}"
}
function echo_info()
{
    str=$1
    color="36"
		str="\n\033[${color}m>>>>>>> ${str}\033[0m"
    echo -e "${str}"
}

# 更新软件对话框
if (whiptail --title "更新软件" --yesno "是否要更新系统内置软件" 10 60) then
	echo_success "You chose yes,start update build-in software..."
  sudo yum update -y
	if [ $? -eq 0 ];then
		echo_success "update success"
	else
		echo_error "update failure"
	fi
else
	echo_warning "You chose No,skip update"
fi

# 检查目录
APP_HOME=/home/app
WWW_HOME=/home/www
SERVER_HOME=/home/server
CONFIG_HOME=/home/config
DOWNLOAD_HOME=/home/download
echo_info 'Checking HOME_DIR'
if [ ! -d $APP_HOME ]; then
	sudo mkdir -p $APP_HOME
fi
if [ ! -d $WWW_HOME ]; then
	sudo mkdir -p $WWW_HOME
fi
if [ ! -d $SERVER_HOME ]; then
	sudo mkdir -p $SERVER_HOME
fi
if [ ! -d $CONFIG_HOME ]; then
	sudo mkdir -p $CONFIG_HOME
fi
if [ ! -d $DOWNLOAD_HOME ]; then
	sudo mkdir -p $DOWNLOAD_HOME
fi

# 安装 git
if (whiptail --title "git" --yesno "是否要安装 git" 10 60) then
	echo_info "start install git"
	sudo yum install -y git
	if [ $? -eq 0 ];then
		echo_success "install git success"
	else
		echo_error "install git failure"
	fi
else
	echo_warning "You chose No,skip install"
fi

# 安装 nginx
if (whiptail --title "nginx" --yesno "是否要安装 nginx" 10 60) then
	echo_info "start install nginx"
	sudo yum install -y nginx
	if [ $? -eq 0 ];then
		echo_success "install nginx success"
		sudo chkconfig nginx on
		sudo service nginx start
		ln -s /etc/nginx/ /home/config/
	else
		echo_error "install nginx failure"
	fi
else
	echo_warning "You chose No,skip install"
fi

# 选择 Node.js 版本
if (whiptail --title "Node.js" --yes-button "Node.js V10.x" --no-button "Node.js V8.x"  --yesno "请选择要安装的Node.js版本" 10 60) then
		echo_info "add node.js V10.x yum repository"
		curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
else
		echo_info "add node.js V8.x yum repository"
		curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
fi
if [ $? -eq 0 ];then
	echo_success "add repository success"
	echo_info "start install node.js"
	sudo yum -y install nodejs
	if [ $? -eq 0 ];then
		echo_success "install node.js success"
	else
		echo_error "install node.js failure"
	fi
else
	echo_error "add repository failure"
fi

# 选择 MongoDB 版本
if (whiptail --title "MongoDB" --yes-button "MongoDB V4.0" --no-button "MongoDB V3.6"  --yesno "请选择要安装的MongoDB版本" 10 60) then
		echo_info "add MongoDB V4.0 yum repository"
		cat>/etc/yum.repos.d/mongodb-org-4.0.repo<<EOF
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc
EOF
else
		echo_info "add MongoDB V3.6 yum repository"
		cat>/etc/yum.repos.d/mongodb-org-4.0.repo<<EOF
[mongodb-org-3.6]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.6/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc
EOF
fi
echo_success "add repository success"
echo_info "start install MongoDB"
sudo yum install -y mongodb-org
if [ $? -eq 0 ];then
	echo_success "install MongoDB success"
	sudo chkconfig mongod on
	ln -s /etc/mongod.conf /home/config/mongod.conf
else
	echo_error "install MongoDB failure"
fi

# 关闭 CentOS 的 THP
if (whiptail --title "Transparent Huge Pages" --yes-button "关闭" --no-button "不关闭"  --yesno "是否关闭 CentOS 7 的 Transparent Huge Pages(THP)，以提高 MongoDB 的系统性能" 10 60) then
		echo_info "disable THP"
		echo ""  >>/etc/rc.d/rc.local
		echo "# for MongoDB , disable thp"  >>/etc/rc.d/rc.local
		echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled"  >>/etc/rc.d/rc.local
		echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag"  >>/etc/rc.d/rc.local
		chmod +x /etc/rc.d/rc.local
else
		echo_info "ignore THP config"
fi

# 安装全局 npm 模块
npm i pm2 -g
echo_success "script finish"
