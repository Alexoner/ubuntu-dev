#!/bin/sh

WORK_USER=Alex

####################################### GLOBAL SETTINGS #######################################

# retry logic to execute a command that might fail
try_do() {
    callback=$1
    error_fix=$2
    export -f $callback

    n=0
    until [ $n -ge 5 ]
    do
      bash -c "$callback" && break  # substitute your command here
      echo "ERROR executing function '$callback', retrying with ${n}th attempt"
      echo "fixing the error, with command: '$error_fix'\n"
      bash -c "$error_fix"
      n=$[$n+1]
      #n=$($n+1)
      sleep 15
    done
    echo "$callback executed successfully!"
}

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
    # install basic requirements: build essential
    echo "=====================installing essential tools====================="
    apt update
    apt install -y --no-install-recommends \
        build-essential \
		make \
        cmake

    apt install -y --no-install-recommends \
        zsh \
        tmux \
        git \
        curl \
        unzip \
        ca-certificates \
		less \
		pkg-config \
        libncurses5-dev libncursesw5-dev xz-utils \
        zlib1g-dev libbz2-dev libreadline-dev libssl-dev libsqlite3-dev
	#apt install -y --no-install-recommends software-properties-common
	chmod -R 755 /usr/local/share/zsh/site-functions
}

setup_user () {
	echo "=====================setting up user $WORK_USER====================="
    #cat <<- EOF >> /usr/bin/setup_user
	#!/bin/sh

    apt install -y --no-install-recommends sudo
	useradd -m -s /bin/zsh $WORK_USER -G sudo || return 0 # ignore error if user already exists
	passwd Alex <<- EOF
	admin
	admin
	EOF

	usermod -a -G staff $WORK_USER

	# enable passwordless sudo
	echo "Alex ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/Alex

	chown $WORK_USER -R /usr/local

}

setup_locale () {
    echo "=====================setting up locale====================="
    apt install -y locales
    locale-gen en_US.UTF-8
}

install_python () {
    echo "=====================installing python====================="
    apt-get install -y \
    libssl-dev zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
	xz-utils tk-dev
    #apt install -y --no-install-recommends \
        #python3.6-venv \
        #python-pip \
        #python3-dev \
        #python3-pip \
        #python-scipy \
        #python-numpy
}

install_shadowsocks () {
	echo "=====================setting up network====================="
    # install shadowsocks
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
    #systemctl restart shadowsocks-libev
    service shadowsocks-libev restart

    cd -
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

install_clang () {
	# install clang compiler
	apt install -y --no-install-recommends clang
}

install_golang () {
	apt install -y --no-install-recommends golang
}

install_rust () {
	apt install -y --no-install-recommends rustc
}

install_computation_dependencies () {
	apt install -y \
		libatlas-base-dev \
		gfortran \
		libeigen3-dev \
		libtbb-dev \
		libtbb2 \
		libhdf5-dev \
		llvm
}

install_opencv_dependencies () {
	# libjasper-dev not available for Ubuntu 17.04, need to install from an earlier release
	apt-get install -y --no-install-recommends \
	pkg-config libavcodec-dev tcl-vtk6 \
    libavformat-dev libswscale-dev libtbb2 libtbb-dev libtiff5-dev libjpeg-dev \
	libdc1394-22-dev unzip libblas-dev liblapack-dev qt5-default \
    libvtk6-dev openjdk-8-jdk libpng-dev libeigen3-dev libtheora-dev ant \
    libvorbis-dev libxvidcore-dev sphinx-common yasm libavutil-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev libavfilter-dev libopenexr-dev  \
    libgstreamer-plugins-base1.0-dev libx264-dev libavresample-dev \
	libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev \
	libgtk-3-dev libgtk2.0-dev libgtkglext1 libgtkglext1-dev \
	libgphoto2-dev \
    #libjasper-dev \

	apt install -y --no-install-recommends \
	libgoogle-perftools-dev 

	# install nonfree opencv
	#add-apt-repository --yes ppa:xqms/opencv-nonfree
	#apt-get update
	#apt-get install -y libopencv-nonfree-dev
}

install_opencv () {
    . ~/.init.sh
    #
    echo "===================== installing opencv =====================$(whoami)"

    cd $HOME
    pip install numpy

    git clone --depth 1 https://github.com/opencv/opencv.git --branch 3.2.0
    git clone --depth 1 https://github.com/opencv/opencv_contrib.git -b 3.2.0

    # disable precompiled headers to avoid 
    # stdlib.h: No such file or directory with gcc 6

    # to specify the flags when building for Python, it's better to fill those
    # parameters from return information of Python interpreter.
    #-DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
    #-DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))")/libpython3.so \
    #-DPYTHON_LIBRARY=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")../../libpython3.so \

    INSTALL_PREFIX=/usr/local
    PYTHON_PREFIX=$(python3 -c "import sys; print(sys.prefix)")

    mkdir opencv/build
    cd opencv/build || return -1
    cmake \
    -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -DBUILD_TIFF=ON \
    -DWITH_CUDA=OFF \
    -DENABLE_AVX=ON \
    -DWITH_GTK_2_X=ON \
    -DWITH_OPENGL=ON \
    -DWITH_OPENCL=ON \
    -DWITH_IPP=ON \
    -DWITH_TBB=ON \
    -DWITH_EIGEN=ON \
    -DWITH_V4L=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DBUILD_opencv_java=OFF \
    -D BUILD_opencv_python3=ON \
    -DPYTHON_EXECUTABLE=$(which python3) \
    -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
    -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    -DCMAKE_INSTALL_PREFIX=$PYTHON_PREFIX \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DENABLE_PRECOMPILED_HEADERS=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF \
    ..
    make -j $(nproc)
    make install

    # create symlinks so that OpenCV is accessible to Python environment 
    #ln -sv $INSTALL_PREFIX/lib/cv.py $(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")/
    ln -sv $INSTALL_PREFIX/lib/python3.6/site-packages/cv2*.so $(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")/

    rm -r $HOME/opencv && rm -r $HOME/opencv_contrib
}

install_ml () {
    source ~/.init.sh
    echo "=====================installing machine learning tools====================="
    pip install keras tensorflow
}

install_dev_tools () {
    echo "=====================installing extra development tools====================="
    apt install -y --no-install-recommends \
        silversearcher-ag \
        exuberant-ctags/zesty \
        rsync \
        less \
        pkg-config
}

install_ops_tools () {
    apt install -y --no-install-recommends \
		coreutils \
		supervisor \
		file \
		openssh-client \
		openssh-server \
        iproute2 \
        lsof \
        iptables \
        usbutils \
        socat \
		#nftables \
		#net-tools \ 

}

setup_display () {
	echo "=====================setting up (fake) display=====================$(whoami)"
    #  Install vnc, xvfb in order to create a 'fake' display
    apt install -y --no-install-recommends \
        supervisor \
        openssh-server pwgen sudo \
        net-tools \
        lxde x11vnc xvfb \
        fonts-wqy-microhei \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        dbus-x11 x11-utils \
        #libreoffice firefox \
        #gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
        #gtk2-engines-murrine ttf-ubuntu-font-family \
        #language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \

	#rm -f /usr/share/applications/x11vnc.desktop

    # Setup a password
    #su $WORK_USER -s "x11vnc -storepasswd 1234 ~/.vnc/passwd"

	git clone --depth 1 https://github.com/kanaka/noVNC.git /usr/lib/noVNC && \
		cd /usr/lib/noVNC && \
		ln -s vnc_auto.html index.html

	# tiny init for containers
	#TINI_VERSION=v0.9.0
	#curl -L https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini -o /bin/tini
	#chmod +x /bin/tini

}

################################### SETUP HOME #########################################

###################################### CLEAN UP ##########################################

clean () {
	echo "=====================cleaning packages=====================$(whoami)"
	apt clean
    rm -rf /var/cache/apt/archives/*
}

if [ $SETUP_MIRROR == "true" -o $SETUP_MIRROR == "TRUE" ]; then
	echo ""
	echo "------------------------------"
	echo "setting up software repository mirror"
	echo "------------------------------"
	echo ""
	setup_mirror
fi

try_do install_essential "apt update --fix-missing"

setup_locale
setup_user

install_neovim

####################################### non-root configuration ##########################
# DONE: use my dev-env repository to synchronize $HOME configurations
su $WORK_USER -c "bash <(curl https://raw.githubusercontent.com/Alexoner/synccf/master/bootstrap.sh -L) --force $INSTALL_MODULES"
#su $WORK_USER -c "curl https://raw.githubusercontent.com/Alexoner/synccf/master/bootstrap.sh -L |bash -s --force"

# execute exported functions as another user
# export -f fun
#su $WORK_USER -c "bash -c fun"

######################################### install modules ###############################
# DONE: run components based on command line arguments
for ARG in "$@"
do
	echo "Configuring $ARG"
        if [ $ARG == "python" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing python"
            echo "------------------------------"
            echo ""
			install_python
        fi
        if [ $ARG == "vim" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing vim"
            echo "------------------------------"
            echo ""
			#install_neovim
        fi
        if [ $ARG == "dev" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing dev"
            echo "------------------------------"
            echo ""
			install_dev_tools
        fi
        if [ $ARG == "ops" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing ops"
            echo "------------------------------"
            echo ""
			install_ops_tools
        fi
        if [ $ARG == "shadowsocks" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing shadowsocks"
            echo "------------------------------"
            echo ""
			install_shadowsocks
        fi
        if [ $ARG == "clang" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing clang compiler."
            echo "------------------------------"
            echo ""
			install_clang
        fi
        if [ $ARG == "ml" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing machine learning packages."
            echo "------------------------------"
            echo ""
			export -f install_ml
			su $WORK_USER -c "bash -c install_ml"
        fi
        if [ $ARG == "opencv" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing opencv."
            echo "------------------------------"
            echo ""
			export -f install_opencv
			try_do install_computation_dependencies "rm -rf /var/cache/apt/* && apt update --fix-missing"
			try_do install_opencv_dependencies "rm -rf /var/cache/apt/* && apt update --fix-missing"
			su $WORK_USER -c "bash -c install_opencv"
        fi
        if [ $ARG == "chinese" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing Chinese language pack."
            echo "------------------------------"
            echo ""
			# TODO: install fonts-wqy-zenhei, fonts-wqy-microhei
        fi
        if [ $ARG == "display" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing Chinese language pack."
            echo "------------------------------"
            echo ""
			setup_display
        fi
        if [ $ARG == "rust" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing rust compiler."
            echo "------------------------------"
            echo ""
			install_rust
        fi
        if [ $ARG == "golang" ] || [ $ARG == "all" ]; then
            echo ""
            echo "------------------------------"
            echo "installing golang compiler."
            echo "------------------------------"
            echo ""
			insatll_golang
        fi
done



# clean up
clean
