# Developing Environment in Ubuntu
#
# VERSION               0.1

FROM ubuntu:16.10
LABEL maintainer onerhao@gmail.com
LABEL Description="Ubuntu for development environment" Vendor="onerhao" Version="0.1"

# Set the locale
# The /etc/default/locale file is loaded by PAM; see /etc/pam.d/login for example. However, PAM is not invoked when running a command in a Docker container. To configure the locale, simply set the relevant environment variable in your Dockerfile
#RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:UTF-8  
ENV LC_ALL en_US.UTF-8

# TODO: change the apt-get mirror in /etc/apt/sources.list and pip mirror in ~/.pip/pip.conf
# otherwise it would be way too slow in China mainland
#RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
#COPY fs/etc/apt/sources.list.ubuntu.aliyun /etc/apt/sources.list

# change pip' mirror url
RUN mkdir ~/.pip # && echo "[global]\n#index-urls:  https://pypi.douban.com, https://mirrors.aliyun.com/pypi,\ncheckout https://www.pypi-mirrors.org/ for more available mirror servers\nindex-url = https://pypi.douban.com/simple\ntrusted-host = pypi.douban.com" > ~/.pip/pip.conf
COPY fs/HOME/.pip/pip.conf ~/.pip

# Copy our install script into the container to execute it later
COPY ./scripts/install.sh /usr/bin/
RUN /usr/bin/install.sh


WORKDIR /workspace
