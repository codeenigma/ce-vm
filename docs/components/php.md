#PHP
[http://www.php.net](http://www.php.net)

## Versions

The following versions are available to choose from, thanks to [https://deb.sury.org](https://deb.sury.org):

- 5.6
- 7.0
- 7.1

## FPM

The php-fpm daemon is listening through an UNIX socket, and can be started/stopped as any standard service, named after the php version. Eg:

```sudo service php7.0-fpm restart```

```sudo service php5.6-fpm restart```

## Libraries

By default, the following libraries/extensions are installed:

- php-mysql
- php-gd
- php-curl
- php-imap
- php-json
- php-opcache
- php-xml
- php-mbstring
- php-memcached
- php-zip

# Tools

The app VM also ships with the following PHP tools:

## Composer

[https://getcomposer.org](https://getcomposer.org)

You can (and probably should) specify a GitHub token to use with Composer to avoid 
hitting the API rate limit,
using the composer_github_oauth_token variable. Preferably set this in your custom 
~/.CodeEnigma/ce-vm/ce-vm-custom/config.yml file instead of the project config.yml.

## PHP_CodeSniffer

[https://getcomposer.org](https://github.com/squizlabs/PHP_CodeSniffer)


## PHP Mess Detector

[https://phpmd.org](https://phpmd.org)

## Xdebug

[https://xdebug.org](https://xdebug.org)

Optional: you can set the php_xdebug variable to 'no' to skip installing it.
