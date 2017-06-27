# Developing Environment in Ubuntu
#
# VERSION               17.04

FROM onerhao/ubuntu-dev:cv

LABEL maintainer onerhao@gmail.com
LABEL Description="Ubuntu for development environment" Vendor="onerhao" Version="17.04"

# Set the locale
# The /etc/default/locale file is loaded by PAM; see /etc/pam.d/login for example. However, PAM is not invoked when running a command in a Docker container. To configure the locale, simply set the relevant environment variable in your Dockerfile
#RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:UTF-8
ENV LC_ALL en_US.UTF-8

# environment variables, options
ARG SETUP_MIRROR

ENV SETUP_MIRROR ${SETUP_MIRROR:-false}
ENV INSTALL_MODULES="display"

RUN echo "Building docker container with mirror: $SETUP_MIRROR, modules: $INSTALL_MODULES"

# it's hammer time now
USER root

# Copy our install script into the container to execute it later
COPY ./scripts/install.sh /usr/bin/


# use environment variables to select modules
RUN bash /usr/bin/install.sh ${INSTALL_MODULES}

ADD fs /
RUN  pip install setuptools wheel && pip install -r /usr/lib/web/requirements.txt

EXPOSE 80 5900 6080 8000 8080 8888

ENV SETUP_MIRROR ""
ENV INSTALL_MODULES ""

USER Alex
#WORKDIR /opt

CMD ["/usr/bin/sudo", "/startup.sh"]
