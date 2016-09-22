#!/bin/sh
set +e
#
# Debian realpath()
#
realpath()
{
    f=$@
    if [ -d "$f" ]; then
        base=""
        dir="$f"
    else
        base="/$(basename "$f")"
        dir=$(dirname "$f")
    fi
    dir=$(cd "$dir" && /bin/pwd)
    echo "$dir$base"
}
#
# INIT / VARS
#
realpath=`realpath`
cores=`grep -c '^processor' /proc/cpuinfo`
user=rehash
pass=rehash
ip="127.0.0.1"
jobs=$((cores*2))
port=80
echo -n "What user would you like to use for rehash (default: $user)? "
read user_input
[ -n "$user_input" ] && user=$user_input
echo -n "How many jobs would you like to run during installation (default: $jobs)? "
read jobs_input
[ -n "$jobs_input" ] && jobs=$jobs_input
echo "Ready to install as $user, with $jobs jobs. (CTL-C to quit, ENTER to continue)"
read nothing
#
# Set local time to UTC
#
# dpkg-reconfigure tzdata
timedatectl set-timezone Etc/UTC &&
apt-get install git \
 build-essential libgd-dev \
 libmysqlclient-dev zlib1g zlib1g-dev libexpat1-dev libssl-dev \
 mysql-server mysql-client -y  &&
#
# Get rehash
#
git clone -b master --single-branch https://github.com/mecctro/rehash.git
#
# Add user locally and to DB
#
adduser $user || true &&
echo "MySQL root access for rehash user installation." &&
mysql -h $ip -e \
 "CREATE DATABASE rehash;
CREATE USER '$user'@'%' IDENTIFIED BY '$pass';
GRANT ALL ON *.* TO '$user'@'%';
FLUSH PRIVILEGES;" -p || true &&
#
# Make default MySQL instance externally accessable
#
sed -i 's/bind-address/#bind-address/g' /etc/mysql/my.cnf &&
service mysql restart &&
#
# Build rehash
#
cd ${realpath}rehash &&
sed -i "s/make \&\&/make -j $jobs \&\&/g" ${realpath}rehash/Makefile || true &&
#sed -i "s/\/bin\/cpanm/bin\/cpanm --notest/g" ${realpath}rehash/Makefile || true &&
sed -i "s/make check/TEST_JOBS=$jobs make test_harness/g" ${realpath}rehash/Makefile || true &&
#sed -i "s/make install/make install -j $jobs/g" ${realpath}rehash/Makefile || true &&
# symlink addresses problem with change in folder name from repo, and apxs defaults
mkdir /opt || true &&
mkdir /opt/rehash-environment || true &&
mkdir /opt/rehash-environment/apache-2.2.29 || true &&
ln -s /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29 || true &&
export PATH=/opt/rehash-environment/perl-5.20.0/bin:$PATH &&
make build-environment USER=$user GROUP=$user install || true &&
cd ${realpath}rehash &&
printf "$user\nmysql\nrehash\n$ip\n3306\n$user\n$pass" | make install-dbix-password &&
make build-environment USER=$user GROUP=$user install &&
export PATH=/opt/rehash-environment/rehash/bin:$PATH &&
#
# Configure rehash
#
printf "\n$user\n$user\n\na\nY\n$user\n$pass\n\n\n" | install-slashsite -u $user &&
#
# Setup and start apache / rehash
#
cd ${realpath} &&
export PATH=/opt/rehash-environment/apache-2.2.29/bin:$PATH &&
# get / fix missing / broken deps / links
sed -i "s/rehash:80/*$port:/g" /opt/rehash-environment/rehash/site/$user/rehash.conf &&
sed -i 's/<VirtualHost/Listen $port\r<VirtualHost/g' /opt/rehash-environment/rehash/site/$user/rehash.conf &&
sed -i 's/Listen 80/Listen 8080/g' /opt/rehash-environment/httpd-2.2.29/conf/httpd.conf &&
head -n -3 /opt/rehash-environment/httpd-2.2.29/conf/httpd.conf &&
cpanm install HTML::PopupTreeSelect &&
template-tool -U -u $user &&
symlink-tool -U -u $user &&
apachectl -k start &&
/etc/init.d/slash start
