FROM mysql:latest

ENV MYSQL_ROOT_PASSWORD password
ENV MYSQL_ROOT_HOST=%

COPY ./shop_server.sql /docker-entrypoint-initdb.d/shop_server.sql