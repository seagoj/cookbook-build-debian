# --- Install packages we need ---
%w(build-essential autoconf automake make autotools-dev dh-make debhelper devscripts fakeroot xutils lintian pbuilder bison libxml2 libxml2-dev libcurl3 libcurl4-gnutls-dev libmagic-dev curl).each do |p|
    package p
end

remote_file "/vagrant/php-5.5.2.tar.bz2" do
    source "http://us3.php.net/get/php-5.5.2.tar.bz2/from/us2.php.net/mirror"
    mode "0777"
end

execute "Expand PHP tarball" do
    cwd "/vagrant"
    user "root"
    command "tar -xvf php-5.5.2.tar.bz2"
end

execute "Begin Debianization" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "cd /vagrant/php-5.5.2 && dh_make --single -e seagoj@gmail.com -f ../php-5.5.2.tar.bz2"
end


execute "Find dependencies" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "dpkg-depcheck -d ./configure --prefix=/usr --sysconfdir=/etc --with-config-file-path=/etc --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-opcache --enable-mbstring --enable-mbregex --enable-zip --with-mysqli --with-openssl --with-curl --with-zlib --enable-pcntl >> ../files/default/dependencies"
end
