| :bangbang: | **This setup is highly experimental. It is meant to be a fast and native alternative for WAMP and the like. This is a Windows equivalent for [macos-lemp-setup](https://github.com/digitoimistodude/macos-lemp-setup). Setup *kinda* works, but it does not have a proper documentation. We do not use Windows machines professionally so it's difficult to keep this up to date and well documented. Included versions may become unsupported at some point and setup script may break from time to time. Consider our [native LEMP server for macOS](https://github.com/digitoimistodude/macos-lemp-setup) instead if you have access to a Mac computer.**  |
|:------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


## Install local LEMP for Windows

Although we use MacOS for web development ([macos-lemp-setup](https://github.com/digitoimistodude/macos-lemp-setup), Windows might still be needed when auditing with Internet Explorer and Edge on different desktop PC or laptop that doesn't have unix OR if we need to test things at home on a Desktop PC we might have. The purpose of this repository is to "easily" get a basic Windows dev environment on **Windows 10 Pro** or newer with Digitoimisto Dude's GitHub projects.

### Prequisites 

1. [Install Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10), install [version 16.04](https://gist.github.com/xynova/87beae35688476efb2ee290d3926f5bb)
2. Mount projects: `sudo rm -rf /var/www && sudo ln -s /mnt/c/Users/yourusername/Projects /var/www`
3. Download and run [install.sh](https://raw.githubusercontent.com/digitoimistodude/windows-lemp-setup/master/install.sh). Sometimes Windows won't run it properly so you might need to Open [install.sh file](https://raw.githubusercontent.com/digitoimistodude/windows-lemp-setup/master/install.sh), select all (<kbd>Ctrl</kbd> + <kbd>A</kbd>), copy (<kbd>Ctrl</kbd> + <kbd>C</kbd>) and paste everything to your Terminal window (<kbd>Ctrl</kbd> + <kbd>V</kbd>). If you have better suggestions on how to run this file properly, please let us know.

**Please note:** Don't trust blindly to the script, use only if you know what you are doing. You can view the file [here](https://github.com/digitoimistodude/windows-lemp-setup/blob/master/install.sh) if having doubts what commands are being run. However, script is tested working many times and should be safe to run even if you have some or all of the components already installed.

### Post install

You should double check your /etc/nginx/php7.conf looks like this, otherwise nothing works:

```` nginx
location ~ \.php$ {
  proxy_intercept_errors on;
  try_files $uri /index.php;
  fastcgi_split_path_info ^(.+\.php)(/.+)$;
  include fastcgi_params;
  fastcgi_read_timeout 300;
  fastcgi_buffer_size 128k;
  fastcgi_buffers 8 128k;
  fastcgi_busy_buffers_size 128k;
  fastcgi_temp_file_write_size 128k;
  fastcgi_index index.php;
  fastcgi_buffering off; # This must be here for WSL as of 11/28/2018
  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  fastcgi_pass 127.0.0.1:9000;
}````

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

Also double check these lines are correct:

```` nginx
listen.allowed_clients = 127.0.0.1, localhost
````

And:

```` nginx
;listen = /run/php/php7.2-fpm.sock
listen = 9000
````

After you restart with these commands you should get Windows Firewall prompt, approve everything.

``` bash
sudo service php7.2-fpm start && sudo service nginx restart
```

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

You cannot directly edit hosts file via WSL/Command line so you should use a tool like [HostsFileEditor](https://github.com/scottlerch/HostsFileEditor).

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

### Databases

As Windows unfortunately doesn't have a great MySQL app like Sequel Pro for macOS, you need to use [Adminer](https://www.adminer.org/). Just get the adminer.php file to somewhere accessible and you can control your databases that way.

If you get no matter what you do:

``` bash
rolle@Infinity:~$ mysql -u root -p
Enter password:
ERROR 1698 (28000): Access denied for user 'root'@'localhost'
```

First make sure you have installed MySQL as instructed [here](https://github.com/digitoimistodude/macos-lemp-setup#post-install) (my.cnf and sudo mysql_secure_installation are the most important part.

After, as instructed [here](https://stackoverflow.com/questions/41645309/mysql-error-access-denied-for-user-rootlocalhost):

``` bash
sudo mysql
```

Then in MariaDB/MySQL console (do not change nothing in following sql commands):

```
update mysql.user set plugin = 'mysql_native_password' where User='root';
FLUSH PRIVILEGES;
exit;
```

Now you should be able to login with password `mysql -u root -p` and use adminer properly.

### SSL certificates and other post installs

Things like HTTPS can be installed the same manner than in [macos-lemp-setup](https://github.com/digitoimistodude/macos-lemp-setup#certificates-for-localhost), practically via [mkcert](https://github.com/FiloSottile/mkcert). Please note: We never got SSL to work successfully on Windows 10. Please let us know if you did!

### Possible issues

Start script doesn't run properly, probably because of Windows character encoding. It can cause issues like this where folder names are mangled:

![Screenshot](https://i.imgur.com/aONfnoq.png)

In this case just rename the files and folders accordingly.
