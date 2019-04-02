## Install local LEMP for Windows

Although we use MacOS for web development ([macos-lemp-setup](https://github.com/digitoimistodude/macos-lemp-setup) and [marlin-vagrant](https://github.com/digitoimistodude/marlin-vagrant)), Windows might still be needed when auditing with Internet Explorer and Edge on different desktop PC or laptop that doesn't have unix. The purpose of this repository is to easily get a basic Windows dev environment on **Windows 10 Pro** or newer with Digitoimisto Dude's GitHub projects.

### Prequisites 

1. [Install Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10), choose Ubuntu 16.04 if possible
2. Mount projects: `sudo mv /var/www/html ~/ && rm -rf /var/www && sudo ln -s /mnt/c/Users/yourusername/Projects /var/www && sudo mv ~/html /var/www/`
3. Select all in install.sh and paste to terminal (for some reason doesn't work by running directly)

**Please note:** Don't trust blindly to the script, use only if you know what you are doing. You can view the file [here](https://github.com/digitoimistodude/windows-lemp-setup/blob/master/install.sh) if having doubts what commands are being run. However, script is tested working many times and should be safe to run even if you have some or all of the components already installed.

### Post install

You may want to add your user and group correctly to `/etc/php/7.2/fpm/pool.d/www.conf` and set these to the bottom:

```` nginx
catch_workers_output = yes
php_flag[display_errors] = On
php_admin_value[error_log] = /var/log/fpm7.2-php.www.log 
slowlog = /var/log/fpm7.2-php.slow.log 
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
    server_name example.test www.example.test;
    include php7.conf;
    include global/wordpress.conf;
}
````

Your `/c/Windows/System32/drivers/etc/hosts` file should always be set up site based like this:

```` bash
127.0.0.1 site.test www.site.tset
127.0.0.1 anothersite.test www.anothersite.test
````

For mysql, remember to run `mysql_secure_installation`. Your logs can be found at `/var/mysql/yourcomputername.err` (where yourcomputername is obviously your hostname).

After that, get to know [dudestack](https://github.com/digitoimistodude/dudestack) to get everything up and running smoothly. Current version of dudestack supports Windows LEMP stack.

### Running LEMP

If for some reason services won't start on startup, you can restart them with these commands:

#### MySQL

``` bash
sudo service mysql start
```

#### nginx

``` bash
sudo service nginx start
```

If you get FAIL, test if config is OK with:

``` bash
sudo nginx -t
```

### php-fpm

``` bash
sudo service php7.2-fpm start
```

If you get FAIL, test if config is OK with:

``` bash
sudo php-fpm7.2 -t
```
