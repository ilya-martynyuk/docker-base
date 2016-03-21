FROM ubuntu:14.04
MAINTAINER Ilya Martynyuk <mescalito1990@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y install apache2 \
    libapache2-mod-php5 \
    php5-mysql \
    php5-gd \
    php5-curl \
    curl lynx-cur \
    mc \
    git \
    subversion

RUN a2enmod php5 &&\
    a2enmod rewrite &&\

    sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini &&\

    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php &&\
    php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '41e71d86b40f28e771d4bb662b997f79625196afcca95a5abf44391188c695c6c1456e16154c75a211d238cc3bc5cb47') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
    php composer-setup.php &&\
    php -r "unlink('composer-setup.php');" &&\
    mv composer.phar /usr/local/bin/composer

ADD apache-config.conf /etc/apache2/sites-available/000-default.conf

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

CMD /usr/sbin/apache2ctl -D FOREGROUND