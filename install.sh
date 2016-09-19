#!/bin/sh
set +e
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
git clone https://github.com/mecctro/rehash &&
#cd rehash &&
#
# Configure MySQL
service mysql stop &&
#wait $! && mysqld --skip-grant-tables || true &
nohup mysqld --skip-grant-tables 2>&1 || true &
#
# Add user locally and to DB
#adduser rehash &&
echo Enter MySQL root password for rehash user installation:
mysql -h 127.0.0.1 -e \
 "CREATE DATABASE rehash;
CREATE USER 'rehash'@'%' IDENTIFIED BY 'rehash';
GRANT ALL ON *.* TO 'rehash'@'%';
FLUSH PRIVILEGES;" -p || true &&
#
# Make default MySQL instance externally accessable
sed -i 's/bind-address/#bind-address/g' /etc/mysql/my.cnf &&
service mysql restart &&
#
# Build rehash
cd rehash &&
make build-environment USER=rehash GROUP=rehash -j 8 || true &&
make build-environment USER=rehash GROUP=rehash -j 8 || true &&
# symlink addresses problem with change in folder name from repo, and apxs defaults
ln -s /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29 || true &&
export PATH=/opt/rehash-environment/perl-5.20.0/bin:$PATH &&
make install-dbix-password &&
make build-environment install -j 8 || true &&
export PATH=/opt/rehash-environment/rehash/bin:$PATH &&
#
# Configure rehash
install-slashsite -u rehash &&

# Setup and start apache / rehash
export PATH=/opt/rehash-environment/apache-2.2.29/bin:$PATH &&
export PATH=/opt/rehash-environment/rehash/bin:$PATH &&
sed -i 's/rehash:80/*:80/g' /opt/rehash-environment/rehash/site/rehash/rehash.conf &&
apachectl -k start &&
/etc/init.d/slash start
