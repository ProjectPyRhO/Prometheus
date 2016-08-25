#!/bin/bash

docker run --name docker-nginx -p 80:80 -v ~/nginx/html:/usr/share/nginx/html -v ~/nginx/default.conf:/etc/nginx/conf.d/default.conf -d nginx
