// Set local time to UTC
//dpkg-reconfigure tzdata
timedatectl set-timezone Etc/UTC &&
apt-get install git \
 build-essential libgd-dev \
 libmysqlclient-dev zlib1g zlib1g-dev libexpat1-dev libssl-dev \
 mysql-server mysql-client -y  &&

// Get rehash
git clone https://github.com/SoylentNews/rehash &&
cd rehash &&

// Configure user
adduser rehash &&

// Build rehash
make build-environment &&
ln -s /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29 &&
export PATH=/opt/rehash-environment/perl-5.20.0/bin:$PATH &&
export PATH=/opt/rehash-environment/rehash/bin:$PATH &&
make build-environment install &&

// Configure rehash
make install-dbix-password &&
install-slashsite -u slash
