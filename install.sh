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
git clone https://github.com/SoylentNews/rehash &&
cd rehash &&
#
# Configure MySQL
#service mysql stop &&
#mysqld --skip-grant-tables &
#
# Add user locally and to DB
#adduser rehash &&
mysql -h 127.0.0.1 -e \
 "CREATE DATABASE rehash;
CREATE USER 'rehash'@'%' IDENTIFIED BY 'rehash';
GRANT ALL ON *.* TO 'rehash'@'%';
FLUSH PRIVILEGES;" -p &&
#
# Make default MySQL instance externally accessable
sed -i 's/bind-address/#bind-address/g' /etc/mysql/my.cnf &&
##service mysql restart &&
#
# Build rehash
make build-environment USER=rehash GROUP=rehash -j 8 &&
ln -s /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29 &&
export PATH=/opt/rehash-environment/perl-5.20.0/bin:$PATH &&
export PATH=/opt/rehash-environment/rehash/bin:$PATH &&
make build-environment install -j 8 &&
#
# Configure rehash
make install-dbix-password &&
install-slashsite -u rehash
