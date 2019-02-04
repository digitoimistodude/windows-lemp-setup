## Install local LEMP for Windows

Although we use MacOS for web development ([macos-lemp-setup](https://github.com/digitoimistodude/macos-lemp-setup) and [marlin-vagrant](https://github.com/digitoimistodude/marlin-vagrant)), Windows might still be needed when auditing with Internet Explorer and Edge on different desktop PC or laptop that doesn't have unix. The purpose of this repository is to easily get a basic Windows dev environment on **Windows 10 Pro** or newer with Digitoimisto Dude's GitHub projects.

### Prequisites 

1. [Install Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10), choose Ubuntu 16.04 if possible
2. Login as root, rename /root to /root2 and mount home to root (naturally replace yourusername with your user name): `sudo ln -s /mnt/c/Users/yourusername /root`
3. Move everything under /root2 to /root and remove /root2.

## Oneliner setup

```` bash
wget -O - https://raw.githubusercontent.com/digitoimistodude/windows-lemp-setup/master/install.sh | bash
````

**Please note:** Don't trust blindly to the script, use only if you know what you are doing. You can view the file [here](https://github.com/digitoimistodude/windows-lemp-setup/blob/master/install.sh) if having doubts what commands are being run. However, script is tested working many times and should be safe to run even if you have some or all of the components already installed.

### Post install

You may want to add your user and group correctly to `/usr/local/etc/php/7.0/php-fpm.d/www.conf` and set these to the bottom:

```` nginx
catch_workers_output = yes
php_flag[display_errors] = On
php_admin_value[error_log] = /var/log/fpm7.0-php.www.log 
slowlog = /var/log/fpm7.0-php.slow.log 
php_admin_flag[log_errors] = On
php_admin_value[memory_limit] = 1024M
request_slowlog_timeout = 10
php_admin_value[upload_max_filesize] = 100M
php_admin_value[post_max_size] = 100M
````

Default vhost could be something like:

```` nginx
server {
    listen 80;
    root /var/www/example;
    index index.html index.htm index.php;
    server_name example.dev www.example.dev;
    include php7.conf;
    include global/wordpress.conf;
}
````

Default my.cnf would be something like this (already added by install.sh in `/usr/local/etc/my.cnf`:

````
#
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
skip-name-resolve
````

For mysql, remember to run `mysql_secure_installation`. Your logs can be found at `/usr/local/var/mysql/yourcomputername.err` (where yourcomputername is obviously your hostname).

After that, get to know [dudestack](https://github.com/digitoimistodude/dudestack) to get everything up and running smoothly. Current version of dudestack supports Windows LEMP stack.

You should remember to add vhosts to your /etc/hosts file, for example: `127.0.0.1 site.test`.
