FROM mysql:latest

ENV MYSQL_ROOT_PASSWORD password
ENV MYSQL_ROOT_HOST=%

COPY ./my_server.sql /docker-entrypoint-initdb.d/my_server.sql