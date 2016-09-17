dpkg-reconfigure tzdata /* Set local time to UTC */
apt-get install git perl-doc -y
apt-get install build-essential libgd-dev \
 libmysqlclient-dev zlib1g zlib1g-dev libexpat1-dev libssl-dev -y
apt-get install mysql-server mysql-client -y

git clone https://github.com/SoylentNews/rehash
cd rehash
// change repo to - http://archive.apache.org/dist/httpd/
// line 343 of Makefile missing double quote @ end
// line 35 of Makefile debian requires nogroup, not nobody
// change perl to 5.24.0
make build-environment install
mv /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29
cpan force  ExtUtils::Embed
make install-dbix-password
