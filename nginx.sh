#!/bin/bash

docker run --name docker-nginx -p 80:80 -v ~/html:/usr/share/nginx/html -v ./default.conf:/etc/nginx/conf.d/default.conf -d nginx
