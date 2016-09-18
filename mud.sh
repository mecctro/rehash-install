/*\wget -O - https://install.perlbrew.pl | bash
source ~/perl5/perlbrew/etc/bashrc
perlbrew install perl-5.20.1
perlbrew switch perl-5.20.1
apt-get libperl-dev apache2-dev -y
make install
make build-environment install
mv /opt/rehash-environment/apache-2.2.29 /opt/rehash-environment/httpd-2.2.29
// perl -MCPAN -e 'upgrade'
/opt/rehash-environment/perl-5.24.0/bin/perl -MCPAN -e "install ModPerl::MM"
/opt/rehash-environment/perl-5.24.0/bin/perl -MCPAN -e "install DateTime"
export PATH=/opt/rehash-environment/perl-5.24.0/bin:$PATH
export PATH=/opt/rehash-environment/rehash/bin:$PATH
/opt/rehash-environment/apache-2.2.29/bin/apxs
/opt/rehash-environment/apache-2.2.29
/opt/rehash-environment/httpd-2.2.29
apt-get install Apache2

cpan -i ExtUtils::Embed
make install-dbix-password

install-slashsite -u slash*/
