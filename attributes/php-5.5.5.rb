default["php-5.5.5".to_sym][:packages] = "bison libxml2 libxml2-dev libcurl3 libcurl4-gnutls-dev libmagic-dev curl"

default["php-5.5.5".to_sym][:config] = "--prefix=/usr --sysconfdir=/etc --with-config-file-path=/etc --enable-fpm --with-interbase --with-fpm-user=www-data --with-fpm-group=www-data --enable-opcache --enable-mbstring --enable-mbregex --enable-zip --with-mysqli --with-openssl --with-curl --with-zlib --enable-pcntl --with-xsl"

default["php-5.5.5".to_sym][:source] = "http://www.php.net/get/php-5.5.5.tar.bz2/from/us1.php.net/mirror"
