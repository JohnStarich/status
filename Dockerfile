# Service status checker
FROM php:5-apache

WORKDIR /var/www/html
ENTRYPOINT ["bash", "entrypoint.sh"]
CMD ["file", "services.json"]

COPY . /var/www/html
