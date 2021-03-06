# nginx + PHP5-FPM + MySQL on Docker
#
# VERSION               0.0.1
FROM        ubuntu:12.04
MAINTAINER  İbrahim YILMAZ "ibrahim@drlinux.org"

VOLUME ["/data/mysql"]
VOLUME ["/data/www"]

# Update packages
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get update

# install curl, wget
RUN apt-get install -y curl wget git subversion imagemagick

# Configure repos
RUN apt-get install -y python-software-properties
RUN apt-get install -y vim
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update

# Install MySQL server
RUN apt-get -y install mysql-server
RUN sed -i "/^datadir*/ s|=.*|=/data/mysql|" /etc/mysql/my.cnf
RUN chown -R mysql:mysql /data/mysql

# Install nginx
RUN apt-get -y install nginx

# tell Nginx to stay foregrounded
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install PHP5 and modules
#

RUN add-apt-repository -y ppa:ondrej/php5-oldstable
RUN apt-get update
RUN apt-get -y install php5-fpm php5-mysql php-apc php5-mcrypt php5-curl php5-gd php5-json php5-cli
RUN sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/fpm/php.ini




RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer



# Configure nginx for PHP websites
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "max_input_vars = 10000;" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = Europe/Istanbul;" >> etc/php5/fpm/php.ini
EXPOSE 80
RUN chown -R www-data:www-data /data/www

#  Install ioncube
RUN cd /usr/local
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz

RUN tar zxvf ioncube_loaders_lin_x86-64.tar.gz

RUN cp ioncube/ioncube_loader_lin_5.4.so /usr/lib/
RUN rm -rf /usr/share/nginx/html/
ADD index.php /data/www/index.php

ADD www.conf /etc/php5/fpm/pool.d/www.conf

ADD php.ini /etc/php5/fpm/php.ini

ADD nginx-site.conf /etc/nginx/sites-available/default
RUN sed -i -e 's/^listen =.*/listen = \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf

RUN apt-get install -y screen
RUN chmod 777 /var/run/screen


#And Start
#
CMD service mysql start; php5-fpm; nginx -c /etc/nginx/nginx.conf
