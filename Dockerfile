# Developing Environment in Ubuntu
#
# VERSION               17.04

FROM ubuntu:17.04
LABEL maintainer onerhao@gmail.com
LABEL Description="Ubuntu for development environment" Vendor="onerhao" Version="17.04"

# Set the locale
# The /etc/default/locale file is loaded by PAM; see /etc/pam.d/login for example. However, PAM is not invoked when running a command in a Docker container. To configure the locale, simply set the relevant environment variable in your Dockerfile
#RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:UTF-8
ENV LC_ALL en_US.UTF-8

# Copy our install script into the container to execute it later
COPY ./scripts/install.sh /usr/bin/
RUN bash /usr/bin/install.sh python neovim shadowsocks spf13


#EXPOSE 8080 80 8000 1080
#WORKDIR /opt

USER Alex
