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
jobs=$((cores*2))
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
git clone https://github.com/mecctro/rehash
#
# Configure MySQL
#
#service mysql stop &&
#wait $! && mysqld --skip-grant-tables || true &
#nohup mysqld --skip-grant-tables >/dev/null 2>&1 || true &
#
# Add user locally and to DB
#
adduser $user || true &&
echo "MySQL root access for rehash user installation." &&
mysql -h 127.0.0.1 -e \
 "CREATE DATABASE rehash;
CREATE USER '$user'@'%' IDENTIFIED BY '$user';
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
sed -i 's/make test/TEST_JOBS=$jobs make test_harness/g' ${realpath}rehash/Makefile &&
make build-environment USER=$user GROUP=$user -j $jobs || true &&
# symlink addresses problem with change in folder name from repo, and apxs defaults
ln -s /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29 || true &&
export PATH=/opt/rehash-environment/perl-5.20.0/bin:$PATH &&
make build-environment install || true -j $jobs &&
export PATH=/opt/rehash-environment/rehash/bin:$PATH &&
#
# Configure rehash
#
cd ${realpath}rehash &&
make install-dbix-password &&
install-slashsite -u $user &&
#
# Setup and start apache / rehash
#
cd ${realpath} &&
export PATH=/opt/rehash-environment/apache-2.2.29/bin:$PATH &&
sed -i 's/rehash:80/*:80/g' /opt/rehash-environment/rehash/site/$user/rehash.conf &&
apachectl -k start &&
/etc/init.d/slash start
