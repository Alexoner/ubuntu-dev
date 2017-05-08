#!/bin/sh

setup_mirror () {
	cd /etc/apt || exit -1
	cp ./sources.list ./sources.list.bak
	cat <<-EOF >>./sources.list
	deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
	EOF
	cd - || exit -1
}

install_essential () {
    # install basic requirements
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        cmake \
        curl \
        unzip \
        python-dev \
        python-pip \
        python3-dev \
        python3-pip \
        python-scipy \
        python-numpy \
        libssl-dev \
        libffi-dev \
        libxml2-dev \
        libxslt-dev \
        software-properties-common
}

setup_network () {
    # install shadowsocks-libev
    apt update
    apt install -y shadowsocks-libev
    cat <<-EOF >> /etc/shadowsocks-libev/config.json
    {
        "server":"example.com or X.X.X.X",
        "server_port":9206,
        "password":"password",
        "timeout":300,
        "method":"aes-256-cfb"
    }
	EOF
    #service shadowsocks-libev restart
    systemctl start shadowsocks-libev
}

setup_locale () {
    locale-gen en_US.UTF-8
}

install_python() {
    su Alex
    virtualenv "$HOME/.python3" -p python3 || exit 1
    exit
}

install_neovim () {
    add-apt-repository ppa:neovim-ppa/unstable -y
    apt update && apt install -y neovim && \
        update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
        update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
        update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 && \
        update-alternatives --config vim && \
        update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 && \
        update-alternatives --config editor
}

setup_spf13 () {
	curl https://raw.githubusercontent.com/Alexoner/spf13-vim/3.0/bootstrap.sh -L |sh -c
}

install_ohmyzsh () {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

setup_user () {
    cat <<- EOF >> /usr/bin/
	#!/bin/sh

	useradd -m Alex || exit 1

	su Alex
	cd $HOME || exit -1
	curl -fsSL https://rawcontent.github.com/Alexoner/bootstrap.sh |sh -c
	exit 0
	EOF
}

setup_display () {
    #  Install vnc, xvfb in order to create a 'fake' display
    apt install -y x11vnc xvfb
    # Setup a password
    x11vnc -storepasswd 1234 ~/.vnc/passwd
}


install_ml () {
    # install tensorflow
    pip3 install tensorflow
}

install_caffe () {
    apt-get install -y --no-install-recommends \
        libatlas-base-dev \
        libboost-all-dev \
        libboost-mpi-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler


    CAFFE_ROOT=/opt/caffe
    #WORKDIR $CAFFE_ROOT

    # FIXME: clone a specific git tag and use ARG instead of ENV once DockerHub supports this.
    CLONE_TAG=master

    git clone -b ${CLONE_TAG} --depth 1 https://github.com/BVLC/caffe.git . && \
        for req in $(cat python/requirements.txt) pydot; do pip install $req; done && \
            mkdir build && cd build && \
            cmake -DCPU_ONLY=1 .. && \
            make -j"$(nproc)"

    PYCAFFE_ROOT=$CAFFE_ROOT/python
    PYTHONPATH=$PYCAFFE_ROOT:$PYTHONPATH
    PATH=$CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
    echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig
}

clean () {
	rm -rf /var/lib/apt/lists/*
}

setup_mirror
install_essential
setup_network
setup_locale
#install_python
install_neovim
#setup_spf13
install_ohmyzsh
#setup_user
setup_display
clean
