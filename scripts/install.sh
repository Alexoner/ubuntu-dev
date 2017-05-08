#!/bin/sh

setup_mirror () {
    cd /etc/apt || exit -1
    cp ./sources.list ./sources.list.default
    #cat <<-EOF >./sources.list
	#deb http://mirrors.aliyun.com/ubuntu/ yakkety main restricted universe multiverse
	#deb http://mirrors.aliyun.com/ubuntu/ yakkety-security main restricted universe multiverse
	#deb http://mirrors.aliyun.com/ubuntu/ yakkety-updates main restricted universe multiverse
	#deb http://mirrors.aliyun.com/ubuntu/ yakkety-proposed main restricted universe multiverse
	#deb http://mirrors.aliyun.com/ubuntu/ yakkety-backports main restricted universe multiverse
	#deb-src http://mirrors.aliyun.com/ubuntu/ yakkety main restricted universe multiverse
	#deb-src http://mirrors.aliyun.com/ubuntu/ yakkety-security main restricted universe multiverse
	#deb-src http://mirrors.aliyun.com/ubuntu/ yakkety-updates main restricted universe multiverse
	#deb-src http://mirrors.aliyun.com/ubuntu/ yakkety-proposed main restricted universe multiverse
	#deb-src http://mirrors.aliyun.com/ubuntu/ yakkety-backports main restricted universe multiverse
	#EOF
    cat <<-EOF >./sources.list
	deb http://mirrors.aliyun.com/ubuntu/ zesty main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ zesty-security main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ zesty-updates main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ zesty-proposed main restricted universe multiverse
	deb http://mirrors.aliyun.com/ubuntu/ zesty-backports main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ zesty main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ zesty-security main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ zesty-updates main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ zesty-proposed main restricted universe multiverse
	deb-src http://mirrors.aliyun.com/ubuntu/ zesty-backports main restricted universe multiverse
	EOF
    cd - || exit -1
}

install_essential () {
    # install basic requirements
    apt update
	echo "installing essential tools"
    apt install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        cmake \
        software-properties-common \
        python-dev \
        python-pip \
        python3.6 \
        python3-dev \
        python3-pip \
        python-scipy \
        python-numpy \
        zsh \
        tmux \
        unzip
}

setup_network () {
    # install shadowsocks-libev
    apt install -y --no-install-recommends shadowsocks-libev
    mkdir -p /etc/shadowsocks-libev || exit -1
    cd /etc/shadowsocks-libev
    cp config.json config.json.default
	cat <<-EOF > /etc/shadowsocks-libev/config.json
	{
		"server":"example.com or X.X.X.X",
		"server_port":9206,
		"password":"password",
		"timeout":300,
		"method":"aes-256-cfb"
	}
	EOF
    #service shadowsocks-libev restart
    #systemctl restart shadowsocks-libev
    service shadowsocks-libev restart
    cd -
}

setup_locale () {
    locale-gen en_US.UTF-8
}

setup_python() {
	pip3 install virtualenvwrapper
    su Alex
    virtualenv "$HOME/.python3" -p python3.6 || exit 1
	pip install setuptools
    exit
}

setup_python_mirror () {
mkdir ~/.pip
# change pip' mirror url
cat <<- EOF  > ~/.pip/pip.conf
[global]
#index-urls:  https://pypi.douban.com, https://mirrors.aliyun.com/pypi,
#checkout https://www.pypi-mirrors.org/ for more available mirror servers
index-url = https://pypi.douban.com/simple
trusted-host = pypi.douban.com
EOF
}

install_neovim () {
    add-apt-repository ppa:neovim-ppa/unstable -y
    apt update
    apt install -y --no-install-recommends neovim && \
        update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
        update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
        update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 && \
        update-alternatives --config vim && \
        update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 && \
        update-alternatives --config editor
	pip install neovim
}

setup_spf13 () {
	su Admin
    curl https://raw.githubusercontent.com/Alexoner/spf13-vim/3.0/bootstrap.sh -L |sh -s
	exit 0
}

install_zsh () {
    apt install -y --no-install-recommends zsh
}

setup_zsh () {
	su Alex
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	exit 0
}

setup_user () {
    #cat <<- EOF >> /usr/bin/setup_user
	#!/bin/sh

	useradd -m Alex || exit 1

	su Alex
	cd $HOME || exit -1
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	exit 0
	#EOF
	#chmod +x /usr/bin/setup_user
}

setup_display () {
    #  Install vnc, xvfb in order to create a 'fake' display
    apt install -y --no-install-recommends x11vnc xvfb
    # Setup a password
    su admin
    x11vnc -storepasswd 1234 ~/.vnc/passwd
    exit 0
}


install_ml () {
    # install tensorflow
    pip3 install tensorflow
}

install_caffe () {
    apt install -y --no-install-recommends \
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
setup_python
install_neovim
install_zsh

setup_user
setup_zsh
setup_spf13
#setup_display
clean
