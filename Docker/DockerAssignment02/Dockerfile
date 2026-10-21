FROM ubuntu:latest

MAINTAINER Yogesh Indoria

RUN apt-get update

RUN apt-get install -y nodejs npm

RUN if [ ! -e /usr/bin/node ]; then ln -s /usr/bin/nodejs /usr/bin/node; fi

RUN npm install -g http-server

COPY index.html /usr/apps/hello-docker/index.html

WORKDIR /usr/apps/hello-docker/

CMD ["http-server", "-s"]