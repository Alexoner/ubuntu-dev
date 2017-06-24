#!/bin/sh

WORK_USER=Alex

setup_mirror () {
    cd /etc/apt || exit -1
    cp ./sources.list ./sources.list.default
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
    cd -
}

install_essential () {
    # install basic requirements
    echo "=====================installing essential tools====================="
    apt update
    apt install -y --no-install-recommends \
        build-essential \
        cmake pkg-config 

    apt install -y --no-install-recommends \
        zsh \
        tmux \
        git \
        curl \
        unzip \
        ca-certificates \
        libncurses5-dev libncursesw5-dev xz-utils \
        zlib1g-dev libbz2-dev libreadline-dev libssl-dev libsqlite3-dev
    #apt install -y --no-install-recommends software-properties-common
}

install_python () {
    echo "=====================installing python====================="

    apt install -y --no-install-recommends \
        python-dev \
        python3.6 \
        python3.6-dev \
        #python3.6-venv \
        #python-pip \
        #python3-dev \
        #python3-pip \
        #python-scipy \
        #python-numpy
}

setup_network () {
    echo "=====================setting up network====================="
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
    echo "=====================setting up locale====================="
    apt install -y locales
    locale-gen en_US.UTF-8
}

install_zsh () {
    apt install -y --no-install-recommends zsh
}

install_neovim () {
    echo "=====================installing neovim====================="
    #add-apt-repository ppa:neovim-ppa/stable -y
    apt install -y --no-install-recommends neovim && \
        update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
        update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && \
        update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 && \
        update-alternatives --config vim && \
        update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 && \
        update-alternatives --config editor
}

install_computation_dependency () {
apt install -y libatlas-base-dev gfortran libeigen3-dev libtbb-dev libtbb2 \
    libhdf5-dev llvm
}

install_image_dependency () {
	apt install -y --no-install-recommends \
		libjpeg8-dev libtiff5-dev \
		libpng12-dev\
		libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev \
		libx264-dev libgtk-3-dev \
		#libjasper-dev \

}

install_opencv () {
	. ~/.init.sh
    #
    echo "=====================installing neovim=====================$(whoami)"

    cd $HOME
    pip install numpy flake8 pep8

    git clone --depth 1 https://github.com/opencv/opencv.git --branch 3.2.0
    #wget https://github.com/opencv/opencv_contrib/archive/3.2.0.zip \
    #&& unzip 3.2.0.zip \
    #&& rm 3.2.0.zip

    git clone --depth 1 https://github.com/opencv/opencv_contrib.git -b 3.2.0
    #wget https://github.com/Itseez/opencv/archive/3.2.0.zip \
    #&& unzip 3.2.0.zip

    mkdir opencv/build \
    && cd opencv/build \
    -DBUILD_TIFF=ON \
    -DBUILD_opencv_java=OFF \
    -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -DWITH_CUDA=OFF \
    -DENABLE_AVX=ON \
    -DWITH_OPENGL=ON \
    -DWITH_OPENCL=ON \
    -DWITH_IPP=ON \
    -DWITH_TBB=ON \
    -DWITH_EIGEN=ON \
    -DWITH_V4L=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
    -DPYTHON_EXECUTABLE=$(which python3.6) \
    -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    ..

    make install
    rm -r $HOME/opencv && rm -r $HOME/opencv_contrib
}

install_ml () {
	echo "=====================installing machine learning tools====================="
    pip install keras tensorflow
}

install_sysadmin () {
	apt install -y --no-install-recommends iproute2 lsof iptables # nftables
}

install_extra () {
	echo "=====================installing extra development tools====================="
	apt install -y --no-install-recommends \
		silversearcher-ag \
		rsync \
		less \
		pkg-config
}

setup_user () {
	echo "=====================setting up user $WORK_USER====================="
    #cat <<- EOF >> /usr/bin/setup_user
	#!/bin/sh

    apt install -y --no-install-recommends sudo
	useradd -m -s /bin/zsh $WORK_USER -G sudo || exit 1
	passwd Alex <<- EOF
	admin
	admin
	EOF
	#useradd -m $WORK_USER -G sudo || exit 1

	#EOF
	#chmod +x /usr/bin/setup_user
	chown $WORK_USER -R /usr/local
}

setup_zsh () {
	echo "=====================setting up zsh=====================$(whoami)"
	export ZSH=""
	cd "$HOME"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	echo 'PROMPT="%{$fg[white]%}%n@%{$fg[green]%}%m%{$reset_color%} ${PROMPT}"' >> ~/.zshrc

	# source a separate init script
	cat <<-EOF >> ~/.zshrc

	############################# custom initialization script ######################### 
	if [ -f \$HOME/.init.sh ]
	then
		. \$HOME/.init.sh
	fi
	EOF

	#exit
}

setup_python_mirror () {
	echo "=====================setting up python mirror=====================$(whoami)"
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

setup_python() {
	echo "=====================setting up python=====================$USER"

	# install Python version manager as a regular user
	curl -L https://raw.github.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
	cat <<- EOF >> ~/.init.sh

	########################## pyenv configuration #########################
	export 'PATH="$HOME/.pyenv/bin:$PATH"'
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
	EOF

	PYTHON_VERSION=3.6.0
	pyenv install $PYTHON_VERSION
	pyenv global $PYTHON_VERSION
	pyenv virtualenv $PYTHON_VERSION alg
	pyenv activate alg
	
	#source ~/.zshrc

	#su - $WORK_USER -c "virtualenv $HOME/.python3 -p python3.6"
	#VENV_DIR=$HOME/.python3
	#python3.6 -m venv $VENV_DIR
	#echo 'source $VENV_DIR/bin/activate' >> ~/.zshrc
	#source $VENV_DIR/bin/activate
	#pip install setuptools
	#pip install virtualenv #virtualenvwrapper
	# TODO: install from requirements.txt
	#deactivate
}

setup_spf13 () {
	source ~/.python3/bin/activate
	pip install neovim
	echo "=====================installing spf13=====================$(whoami)"
    curl https://raw.githubusercontent.com/Alexoner/spf13-vim/3.0/bootstrap.sh -L |sh -s
	#exit
}

setup_display () {
	echo "=====================setting up (fake) display=====================$(whoami)"
    #  Install vnc, xvfb in order to create a 'fake' display
    apt install -y --no-install-recommends x11vnc xvfb
    # Setup a password
    su $WORK_USER -s "x11vnc -storepasswd 1234 ~/.vnc/passwd"
}

clean () {
	echo "=====================cleaning packages=====================$(whoami)"
	apt clean
    rm -rf /var/cache/apt/archives/*
}

#setup_mirror
install_essential

install_python
install_neovim

setup_network
setup_locale
setup_user

# non-root configuration, execute as another user
su $WORK_USER -c "bash <(curl https://raw.githubusercontent.com/Alexoner/synccf/master/bootstrap.sh -L)"
# export functions
#export -f setup_zsh
#export -f setup_python_mirror
#export -f setup_python
#export -f setup_spf13
export -f setup_display
export -f install_ml
export -f install_opencv

# execute exported functions as another user
#su $WORK_USER -c "bash -c setup_zsh"
#su $WORK_USER -c "bash -c setup_python_mirror"
#su $WORK_USER -c "bash -c setup_python"
#su $WORK_USER -c "bash -c setup_spf13"
su $WORK_USER -c "bash -c install_ml"

install_image_dependency
su $WORK_USER -c "bash -c install_opencv"

#setup_display
#su $WORK_USER -c "bash -c setup_display"

install_extra
install_sysadmin

# clean up
clean
