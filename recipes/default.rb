# --- Install packages we need ---
require 'rubygems'
require 'json'
packages = %w(build-essential autoconf automake make autotools-dev dh-make debhelper devscripts fakeroot xutils lintian pbuilder)

packages += JSON.parse(open("/vagrant/packages.json").read) if File.exists?("/vagrant/packages.json")

packages.each do |p|
    package p
end

# Reuse or pull down source archive
if File.exists?("/vagrant/php_5.5.2.orig.tar.bz2")
    execute "Cleanup" do
        cwd "/vagrant"
        user "root"
        command "rm -r php-5.5.2 php-5.5.2.tar.bz2 && mv php_5.5.2.orig.tar.bz2 php-5.5.2.tar.bz2"
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

execute "Begin Debianization" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "cd /vagrant/php-5.5.2 && dh_make --single -e seagoj@gmail.com -f ../php-5.5.2.tar.bz2"
end

execute "Find dependencies" do
    cwd "/vagrant/php-5.5.2"
    user "root"
    command "dpkg-depcheck -d ./configure --prefix=/usr --sysconfdir=/etc --with-config-file-path=/etc --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-opcache --enable-mbstring --enable-mbregex --enable-zip --with-mysqli --with-openssl --with-curl --with-zlib --enable-pcntl >> ../dependencies"
end

depends = File.open("/vagrant/dependencies").read
control = File.open("/vagrant/files/default/control").read
depHeader = "Packages needed:\n"
conHeader = "Build-Depends: "

append = ", " + depends.slice(depends.rindex(depHeader)+depHeader.length, depends.length).split("\n").each{|d| d.strip!}.join(", ")
newControl = control.insert(control.index("\n", control.index(conHeader)+conHeader.length), append)
File.open("/vagrant/php-5.5.2/debian/control", "w") { |file| file.write(newControl) }

#cookbook_file "/vagrant/php-5.5.2/debian/control" do
#    source "control"
#end

#execute "Build Debian File" do
#    cwd "/vagrant/php-5.5.2"
#    user "root"
#    command "dpkg-buildpackage -rfakeroot"
#end

#execute "Testing package" do
#    cwd "/vagrant"
#    user "root"
#    command "lintian -Ivi php-5.5.2.changes"
#end
