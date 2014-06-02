default[:build_debian][:user] = "root"
default[:build_debian][:group] = "root"
default[:build_debian][:php-5.5.2_config] = "--prefix=/usr --sysconfdir=/etc --with-config-file-path=/etc --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-opcache --enable-mbstring --enable-mbregex --enable-zip --with-mysqli --with-openssl --with-curl --with-zlib --enable-pcntl"
default[:build_debian][:php-5.5.2_source] = "http://www.php.net/get/php-5.5.2.tar.bz2/from/us1.php.net/mirror"
