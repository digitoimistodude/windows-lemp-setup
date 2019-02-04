#!/bin/bash
# Install script for LEMP on Windows - by ronilaukkarinen.

# Helpers:
txtbold=$(tput bold)
boldgreen=${txtbold}$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
green=$(tput setaf 2)
white=$(tput setaf 7)
txtreset=$(tput sgr0)

echo "${yellow}Updating apt...${txtreset}"
sudo apt-get update
echo "${boldgreen}Dependencies installed and up to date.${txtreset}"
echo "${yellow}Installing nginx.${txtreset}"
sudo apt-get install nginx-full -y
sudo systemctl enable nginx
sudo service nginx start
echo "${boldgreen}nginx installed and running.${txtreset}"
echo "${yellow}Setting up nginx.${txtreset}"
sudo mkdir -p /etc/nginx/global
sudo mkdir -p /etc/nginx/sites-enabled
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/global
sudo chmod -R 775 /etc/nginx/sites-enabled
sudo chmod -R 775 /etc/nginx/sites-available
sudo chmod -R 775 /etc/nginx/global
sudo echo "worker_processes 8;

events {  
        multi_accept on;
        accept_mutex on;
        worker_connections 1024;
}

http {  

        ##  
        # Optimization  
        ##  
  
        sendfile on;
        sendfile_max_chunk 512k;
        tcp_nopush on;  
        tcp_nodelay on;  
        keepalive_timeout 120;
        keepalive_requests 100000;  
        types_hash_max_size 2048;
        server_tokens off;
        client_body_buffer_size      128k;  
        client_max_body_size         10m;  
        client_header_buffer_size    1k;  
        large_client_header_buffers  4 32k;  
        output_buffers               1 32k;  
        postpone_output              1460;
  
        server_names_hash_max_size 1024;  
        #server_names_hash_bucket_size 64;  
        # server_name_in_redirect off;  
  
        include /etc/nginx/mime.types;  
        default_type application/octet-stream;  

        ##
        # Logging Settings
        ##
        access_log off;
        access_log /var/log/nginx/access.log combined;
        error_log /var/log/nginx/error.log;

        ##
        # Virtual Host Configs
        ##
        
        include /etc/nginx/sites-enabled/*;
}" > "/etc/nginx/nginx.conf"
sudo mkdir -p /var/log/nginx
sudo touch /var/log/nginx/access.log
sudo chmod 777 /var/log/nginx/access.log
sudo touch /var/log/nginx/error.log
sudo chmod 777 /var/log/nginx/error.log
sudo echo "location ~ \.php\$ {
  proxy_intercept_errors on;
  try_files \$uri /index.php;
  fastcgi_split_path_info ^(.+\.php)(/.+)\$;
  include fastcgi_params;
  fastcgi_read_timeout 300;
  fastcgi_buffer_size 128k;
  fastcgi_buffers 8 128k;
  fastcgi_busy_buffers_size 128k;
  fastcgi_temp_file_write_size 128k;
  fastcgi_index index.php;
  fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
  fastcgi_pass 127.0.0.1:9000;
}" > "/etc/nginx/php7.conf"
sudo echo "# WordPress single site rules.
# Designed to be included in any server {} block.
# Upstream to abstract backend connection(s) for php
location = /favicon.ico {
        log_not_found off;
        access_log off;
}

location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
}

location / {
        # This is cool because no php is touched for static content.
        # include the "?\$args" part so non-default permalinks doesn't break when using query string
        try_files \$uri \$uri/ /index.php?\$args;
}

# Add trailing slash to */wp-admin requests.
rewrite /wp-admin\$ \$scheme://\$host\$uri/ permanent;

# Directives to send expires headers and turn off 404 error logging.
location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)\$ {
       access_log off; log_not_found off; expires max;
}" > "/etc/nginx/global/wordpress.conf"
sudo echo "server {
        listen 80 default_server;
        root html;
        index index.html index.htm index.php;
        server_name localhost;
        include php7.conf;
        #include global/wordpress.conf;
}" > "/etc/nginx/sites-available/default"
sudo ln -sfnv /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
echo "${yellow}Installing PHP.${txtreset}"
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get install php7.2-cli php7.2-common php7.2-curl php7.2-fpm php7.2-gd php7.2-imap php7.2-intl php7.2-json php7.2-mbstring php7.2-mysql php7.2-opcache php7.2-pspell php7.2-readline php7.2-recode php7.2-soap php7.2-sqlite3 php7.2-tidy php7.2-xml php7.2-xmlrpc php7.2-xsl -y
sudo touch /var/log/fpm7.0-php.slow.log
sudo chmod 775 /var/log/fpm7.0-php.slow.log
sudo chown "$USER":staff /var/log/fpm7.0-php.slow.log
sudo touch /var/log/fpm7.0-php.www.log
sudo chmod 775 /var/log/fpm7.0-php.www.log
sudo chown "$USER":staff /var/log/fpm7.0-php.www.log
sudo service php7.2-fpm start
sudo systemctl enable php7.2-fpm
sudo php-fpm7.2 -t
echo "${boldgreen}PHP installed and running.${txtreset}"
echo "${yellow}Installing MariaDB.${txtreset}"
sudo apt-get install -y software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.1/ubuntu xenial main'
sudo apt -y update
sudo apt-get install -y mariadb-client libmariadbd-dev
sudo echo "#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

#
# include all files from the config directory
#
!includedir /usr/local/etc/my.cnf.d

[mysqld]
innodb_log_file_size = 32M
innodb_buffer_pool_size = 1024M
innodb_log_buffer_size = 4M
slow_query_log = 1
query_cache_limit = 512K
query_cache_size = 128M
skip-name-resolve" > "/etc/my.cnf"
echo "${boldgreen}MariaDB installed and running.${txtreset}"
echo "${yellow}Restarting services....${txtreset}"
sudo service mysql restart
sudo service nginx restart
sudo service php7.2-fpm restart
# These need to be running as root, because of the port 80 and other privileges.

echo "${boldgreen}You should now be able to use http://localhost. If not, test with commands sudo nginx -t and sudo php-fpm7.2 -t and fix errors if any. Add new vhosts to /etc/nginx/sites-available and symlink them just like you would do in production. Have fun!${txtreset}"
