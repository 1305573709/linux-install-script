#!/bin/sh
#------------------------------------------
#      Centos7 Install Helper
#      copyright https://github.com/cjy37
#      email: rocky.cn@foxmail.com
#------------------------------------------

function showMenu()
{
	clear
	echo
	echo "--------------------------------------------------------------"
	echo "|      Centos7 Install Helper                                |"
	echo "|      ��Ȩ���� https://github.com/cjy37                     |"
	echo "--------------------------------------------------------------"
	echo "|      a. ��װ Docker ���л���                               |"
	echo "|      b. ��װ Rancher (Docker����̨)                        |"
	echo "|      # c. ��װ MySQL   ����  (���Ƽ�, ����Docker��ʽ)      |"
	echo "|      # d. ��װ MongoDB ����  (���Ƽ�, ����Docker��ʽ)      |"
	echo "|      # e. ��װ MQTT    ����  (���Ƽ�, ����Docker��ʽ)      |"
	echo "|      # f. ��װ Redis   ����  (���Ƽ�, ����Docker��ʽ)      |"
	echo "|      # g. ��װ Nginx   ����  (���Ƽ�, ����Docker��ʽ)      |"
	echo "|      # h. ��װ Haproxy ����  (���Ƽ�, ����Docker��ʽ)      |"
	echo "|      i. ��װ NFS ����洢                                  |"
	echo "|      x. �˳�                                               |"
	echo "--------------------------------------------------------------"
	echo
	
	return 0
}

function selectCmd()
{
	alias cp='cp'
	showMenu
	echo "��ѡ��Ҫ��װ����ĸ��� [a-x]:"
	read -n 1 M
	echo

	if [ "$M" = "x" ]; then
		exit 1
		
	elif [ "$M" = "a" ]; then
		echo "��װ Docker ���л���"
		echo "------------------------------------"
		setupDocker
		read -n 1 -p "�� <Enter> ����..."
		
	elif [ "$M" = "b" ]; then
		echo "��װ Rancher ����"
		echo "------------------------------------"
		setupRancher
		read -n 1 -p "�� <Enter> ����..."

	elif [ "$M" = "c" ]; then
		echo "��װ MySQL ����"
		echo "------------------------------------"
		setupMysql
		read -n 1 -p "�� <Enter> ����..."

	elif [ "$M" = "d" ]; then
		echo "��װ MongoDB ����"
		echo "------------------------------------"
		setupMongodb
		read -n 1 -p "�� <Enter> ����..."
		
	elif [ "$M" = "e" ]; then
		echo "��װ MQTT ����Mosquitto��"
		echo "------------------------------------"
		setupMosquitto
		read -n 1 -p "�� <Enter> ����..."
    
    elif [ "$M" = "f" ]; then
		echo "��װ Redis ����"
		echo "------------------------------------"
		setupRedis
		read -n 1 -p "�� <Enter> ����..."
	
    elif [ "$M" = "g" ]; then
		echo "��װ Nginx ����"
		echo "------------------------------------"
		setupNginx
		read -n 1 -p "�� <Enter> ����..."
   
	elif [ "$M" = "h" ]; then
		echo "��װ Haproxy ����"
		echo "------------------------------------"
		setupHaproxy
		read -n 1 -p "�� <Enter> ����..."

	elif [ "$M" = "i" ]; then
		echo "��װ NFS ����洢"
		echo "------------------------------------"
		setupNFS
		read -n 1 -p "�� <Enter> ����..."

	else
		echo "ѡ�����!"
		read -n 1 -p "�� <Enter> ����..."
	fi

	selectCmd
	return 0
}

function setupDocker()
{

    # ɾ���ɵ����
	sudo yum remove docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-selinux \
        docker-engine-selinux \
        docker-engine

    # ��װ����
	sudo yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2

    # ��װDocker
    curl https://releases.rancher.com/install-docker/17.03.sh | sh
    
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://y1q9bgae.mirror.aliyuncs.com"]
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
	return $?
}

function setupRancher()
{
	echo "install rancher"
	echo "------------------------------------"
	
	sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server

	return $?
}


function setupMysql()
{
	echo "��װ mysql"
	echo "------------------------------------"
	
	echo '# MariaDB 10.0 CentOS repository list - created 2014-10-18 16:58 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1' > /etc/yum.repos.d/MariaDB.repo

	yum -y install MariaDB-server MariaDB-client MariaDB-devel
	cp /usr/share/mysql/my-innodb-heavy-4G.cnf /etc/my.cnf
	#sudo sed -i 's/# generic configuration options/user = mysql/g' /etc/my.cnf
	sudo sed -i '/\[mysqld\]/a user = mysql' /etc/my.cnf
	chkconfig --level 2345 mysql on
	service mysql start
	
	mysql -V
	echo "------------------------------------"
	echo "Mysql: Please Ender user(root) password"
	read -e PWD
	mysqladmin -uroot password "$PWD"
	return $?
}

function setupMongodb()
{
	echo "install Mongodb"
	echo "------------------------------------"
	yum -y install mongodb mongodb-server
	echo "Install mongodb completed. info:"
	mongod --version
	echo "------------------------------------"
	return $?
}


function setupMosquitto()
{
	echo "install Mosquitto"
	echo "------------------------------------"
	
	echo '[home_oojah_mqtt]
name=mqtt (CentOS_CentOS-7)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-7/
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-7/repodata/repomd.xml.key
enabled=1
' > /etc/yum.repos.d/Mosquitto.repo

	yum -y install mosquitto mosquitto-clients libmosquitto1 libmosquitto-devel libmosquittopp1 libmosquittopp-devel python-mosquitto

	mosquitto -h
	echo "------------------------------------"

	return $?
}

function setupRedis()
{
	echo "install redis"
	echo "------------------------------------"
	yum -y install redis
	echo "Install Redis completed. info:"
	redis-server -v
	echo "------------------------------------"
	return $?
}


function setupNginx()
{

	echo "install nginx"
	echo "------------------------------------"

	echo '[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1' > /etc/yum.repos.d/nginx.repo
	yum -y install nginx
	chkconfig --level 2345 nginx on
	service nginx start
	nginx -v
	echo "------------------------------------"
	return $?
}

function setupHaproxy()
{
	echo "install haproxy"
	echo "------------------------------------"
	yum -y install haproxy
	echo "Install haproxy completed. info:"
	haproxy -v
	echo "------------------------------------"
	return $?
}

function setupNFS()
{
	echo "install nfs"
	echo "------------------------------------"
	yum install -y nfs-utils rpcbind
    echo " ���rpcbind�Ƿ񿪻�����"
    systemctl list-unit-files | grep rpcbind.service
    systemctl enable rpcbind.service
    echo "����rpcbind����"
    systemctl restart rpcbind.service
    echo " �鿴rpc"
    netstat -lntup|grep rpcbind
    echo " �鿴nfs������rpcע��Ķ˿���Ϣ"
    rpcinfo -p localhost
    
    echo
    echo " ���NFS�Ƿ񿪻�����"
    systemctl list-unit-files | grep nfs.service
    systemctl enable nfs.service
    echo "����NFS����"
    echo "/wwwroot 172.16.7.0/24(rw,sync,all_squash)" > /etc/exports
    chown -R nfsnobody.nfsnobody /wwwroot
    systemctl restart nfs.service
    exportfs -rv
    echo "====== ���������� ======"
    echo "vim /etc/exports"
    echo "exports�ļ����ø�ʽ:\
NFS�����Ŀ¼ NFS�ͻ��˵�ַ1(����1,����2,...) �ͻ��˵�ַ2(����1,����2,...)\
Ҫ�þ���·�����ɱ�nfsnobody��д��\
���磺\
# /wwwroot 172.16.7.0/24(rw,sync,all_squash)\
"

	return $?
}


function setupOs7Epel()
{
	echo "Install Centos7_64bit EPEL repository"
	sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
	sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
	sudo yum -y install yum-priorities
	
	return $?
}

function setupOs6Epel()
{
	echo "Install Centos6_64bit EPEL repository"
	rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	yum -y install yum-priorities
	
	return $?
}

function setupOs5Epel()
{
	echo "Install Centos5_64bit EPEL repository"
	rpm -ivh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5
	yum -y install yum-priorities
	
	return $?
}

function setupFedoraEpel()
{
	vers=`cat /etc/redhat-release | awk -F'release' '{print $2}' | awk -F'.' '{print $1}' | awk -F' ' '{print $1}'`
	if [ "$vers" = "7" ]; then
		setupOs7Epel
	elif [ "$vers" = "6" ]; then
		setupOs6Epel
	elif [ "$vers" = "5" ]; then
		setupOs5Epel
	fi

	sudo yum -y update
	sudo yum -y groupinstall "Development Tools"
	echo "��װDocker..."
	echo "------------------------------------"

	if [ ! -d /wwwroot ]; then
	  mkdir -pv /wwwroot
	fi
    
	return $?
}


cd /tmp

read -n 1 -p "���������װDocker���. �� [Ctrl + C] ȡ����װ."
setupFedoraEpel
selectCmd
