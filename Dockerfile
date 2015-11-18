# Service Status Website
FROM php:5-apache
MAINTAINER John Starich <john.starich@thirdship.com>

COPY . /var/www/html
WORKDIR /var/www/html

ENTRYPOINT ["bash", "entrypoint.sh"]
