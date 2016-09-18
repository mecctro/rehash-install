dpkg-reconfigure tzdata /* Set local time to UTC */
apt-get install git perl-doc -y
apt-get install git \
 build-essential libgd-dev \
 libmysqlclient-dev zlib1g zlib1g-dev libexpat1-dev libssl-dev \
 mysql-server mysql-client -y

git clone https://github.com/SoylentNews/rehash
cd rehash
// change repo to - http://archive.apache.org/dist/httpd/
// line 343 of Makefile missing double quote @ end
// line 35 of Makefile debian requires nogroup, not nobody
// change perl to 5.24.0?
// change perl to 5.20.1

\wget -O - https://install.perlbrew.pl | bash
perlbrew install perl-5.20.1
perlbrew switch perl-5.20.1

make build-environment install
mv /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29
perl -MCPAN -e 'upgrade'
perl -MCPAN -e "install ModPerl::MM"
/opt/rehash-environment/apache-2.2.29/bin/apxs
/opt/rehash-environment/apache-2.2.29
/opt/rehash-environment/httpd-2.2.29
apt-get install Apache2

cpan -i ExtUtils::Embed
make install-dbix-password
