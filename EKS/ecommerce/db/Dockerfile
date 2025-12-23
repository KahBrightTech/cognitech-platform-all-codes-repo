# Use official PostgreSQL image
FROM postgres:15-alpine
ENV POSTGRES_DB=ecomdb
ENV POSTGRES_USER=ecomuser
ENV POSTGRES_PASSWORD=ecompass
COPY init.sql /docker-entrypoint-initdb.d/
