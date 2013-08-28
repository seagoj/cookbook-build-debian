# --- Install packages we need ---
require 'rubygems'
require 'json'
packages = %w(checkinstall automake build-essential make auto-apt)
packages += JSON.parse(open("/vagrant/packages.json").read) if File.exists?("/vagrant/packages.json")
packages.each{ |p| package p }

builds = `ls *.tgz`+`ls *.tar.gz`+`ls *.bz2`
puts builds

%w(php-5.5.2 php-5.5.2.tar.bz2 dependencies php_5.5.2-1.debian.tar.gz).each do |f|
    if File.exists?("/vagrant/#{f}")
        execute "Cleanup #{f}" do
            cwd "/vagrant"
            user "root"
            command "rm -r #{f}"
        end
    end
end

# Reuse or pull down source archive
if File.exists?("/vagrant/php_5.5.2.orig.tar.bz2")
    execute "Reuse php_5.5.2.orig.tar.bz2" do
            cwd "/vagrant"
            user "root"
            command "mv php_5.5.2.orig.tar.bz2 php-5.5.2.tar.bz2"
    end
else
    remote_file "/vagrant/php-5.5.2.tar.bz2" do
        source "http://us3.php.net/get/php-5.5.2.tar.bz2/from/us2.php.net/mirror"
        mode "0777"
    end
end

execute "Expand PHP tarball" do
    cwd "/vagrant"
    user "root"
    command "tar -xvf php-5.5.2.tar.bz2"
end

execute "Configure" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "auto-apt run ./configure --prefix=/usr --sysconfdir=/etc --with-config-file-path=/etc --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-opcache --enable-mbstring --enable-mbregex --enable-zip --with-mysqli --with-openssl --with-curl --with-zlib --enable-pcntl"
end

execute "Make" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "make"
    timeout 7200
end

execute "Make Test" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "make test"
    timeout 7200
end

execute "Build" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "checkinstall"
    timeout 7200
end

execute "Move Debian" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "mv *.deb .."
end
