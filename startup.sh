#!/bin/bash
exec >> /var/www/html/startup.log 2>&1

unzip -qq /tmp/webmail-pro-php.zip -d /var/www/html
mv /tmp/afterlogic.php /var/www/html/

tee -a /etc/apache2/sites-available/000-default.conf << EOF
<Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
</Directory>
<FilesMatch \.php$>
        SetHandler application/x-httpd-php
</FilesMatch>
EOF

# enable php short tags:
/bin/sed -i "s|short_open_tag = Off|short_open_tag = On|g" /etc/php/8.1/apache2/php.ini
# Set PHP timezone
/bin/sed -i 's|;date.timezone =|date.timezone = '${TZ}'|g' /etc/php/8.1/apache2/php.ini
/bin/sed -i "s|upload_max_filesize = 2M|upload_max_filesize = 256M|g" /etc/php/8.1/apache2/php.ini
/bin/sed -i "s|post_max_size = 8M|post_max_size = 512M|g" /etc/php/8.1/apache2/php.ini
/bin/sed -i "s|;opcache.enable=1|opcache.enable=1|g" /etc/php/8.1/apache2/php.ini
/bin/sed -i "s|;opcache.memory_consumption=128|opcache.memory_consumption=128|g" /etc/php/8.1/apache2/php.ini
/bin/sed -i "s|;opcache.max_accelerated_files=10000|opcache.max_accelerated_files=30000|g" /etc/php/8.1/apache2/php.ini
/bin/sed -i "s|;opcache.revalidate_freq=2|opcache.revalidate_freq=0|g" /etc/php/8.1/apache2/php.ini
/bin/sed -i "s|;opcache.optimization_level=0x7FFFBFFF|opcache.optimization_level=0xFFFFFBFF|g" /etc/php/8.1/apache2/php.ini

tee -a /etc/php/8.1/apache2/php.ini << EOF
; JIT
opcache.jit_buffer_size=64M
opcache.jit=tracing
EOF
rm -f /var/www/html/index.html

#internal compatibility with my projects
chown www-data:root -R /var/www/html/* 
chmod 755 -R /var/www/html
a2enmod rewrite
a2enmod ssl
a2ensite default-ssl

/usr/sbin/apache2ctl -D FOREGROUND

echo "===========> Done <============"
