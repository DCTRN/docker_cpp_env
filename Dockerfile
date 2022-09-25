FROM ubuntu:20.04

RUN mkdir /var/fpwork

VOLUME /var/fpwork
VOLUME /usr
VOLUME /home
VOLUME /lib
VOLUME /etc

RUN apt-get update && apt-get upgrade

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y git \
  g++ \
  make \
  build-essential \
  wget \
  libgtk-3-dev \
  lubuntu-desktop \
  lightdm \
  libcurl4 \
  openssl \
  liblzma5

RUN apt-get install -y cmake pkg-config
RUN apt-get install -y mesa-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev
RUN apt-get install -y libglew-dev libglfw3-dev libglm-dev
RUN apt-get install -y libao-dev libmpg123-dev
RUN apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
  gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

RUN apt-get install -y libsecret-1-0
RUN apt-get install -y libgtk2.0-0
RUN apt-get install -y libnss3
RUN apt-get install -y libxtst6
RUN apt-get install -y xdg-utils
RUN apt-get install -y libgconf-2-4
RUN apt-get install -y libxss1
RUN apt-get install -y kde-cli-tools
RUN apt-get install -y libglib2.0-bin
RUN apt-get install -y gvfs-bin
RUN apt-get install -y trash-cli
RUN apt-get install -y gnome-keyring
RUN apt-get install -y kdepim-runtime
RUN apt-get install -y expect

COPY install_libnotify4.exp /home/install_libnotify4.exp
RUN expect /home/install_libnotify4.exp

RUN apt-get install -y sqlite3 sqlitebrowser

# RUN rm /run/reboot-required*
RUN echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
RUN echo "\
[LightDM]\n\
[Seat:*]\n\
type=xremote\n\
xserver-hostname=host.docker.internal\n\
xserver-display-number=0\n\
autologin-user=root\n\
autologin-user-timeout=0\n\
autologin-session=Lubuntu\n\
" > /etc/lightdm/lightdm.conf.d/lightdm.conf

ENV DISPLAY=host.docker.internal:0.0

RUN cd /home && wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.1/wxWidgets-3.2.1.tar.bz2 \
  && tar xfj wxWidgets-3.2.1.tar.bz2 \
  && rm -rf wxWidgets-3.2.1.tar.bz2 \
  && cd wxWidgets-3.2.1 \
  && mkdir gtk-build \
  && cd gtk-build \
  && ../configure --enable-debug --with-opengl --with-gtk=3 --enable-mediactrl \
  && make -j $(($(nproc)-2)) \
  && make -j $(($(nproc)-2)) install \
  && make clean \
  && ldconfig \
  && cd /home \
  && rm -rf wxWidgets-3.2.1

RUN cd /home && wget https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.gz \
  && tar xfz jansson-2.14.tar.gz \
  && rm jansson-2.14.tar.gz \
  && cd jansson-2.14 \
  && ./configure \
  && make -j $(($(nproc)-2)) \
  && make -j $(($(nproc)-2)) install \
  && make clean \
  && cd .. \
  && rm -rf jansson-2.14

RUN cd /home && wget https://downloads.sourceforge.net/project/boost/boost/1.80.0/boost_1_80_0.tar.gz \
  && tar xfz boost_1_80_0.tar.gz \
  && rm boost_1_80_0.tar.gz \
  && cd boost_1_80_0 \
  && ./bootstrap.sh \
  && ./b2 install \
  && cd /home \
  && rm -rf boost_1_80_0

RUN cd /home && wget https://github.com/google/googletest/archive/refs/tags/release-1.12.1.tar.gz\
  && tar xfz release-1.12.1.tar.gz \
  && rm release-1.12.1.tar.gz \
  && cd googletest-release-1.12.1 \
  && cmake -S . -B build \
  && cmake --build build \
  && cd build \
  && make -j $(($(nproc)-2)) install \
  && make clean \
  && ldconfig \
  && cd .. \
  && rm -rf googletest-release-1.12.1

RUN cd /home && wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-6.0.1.tgz \
  && tar -zxvf mongodb-linux-x86_64-ubuntu2004-6.0.1.tgz \
  && rm mongodb-linux-x86_64-ubuntu2004-6.0.1.tgz \
  && mv mongodb-linux-x86_64-ubuntu2004-6.0.1 mongodb \
  && ln -s /home/mongodb/bin/* /usr/local/bin/ \
  && mkdir -p /var/lib/mongo \
  && mkdir -p /var/log/mongodb \
  && chown `whoami` /var/lib/mongo \
  && chown `whoami` /var/log/mongodb

RUN cd /home && wget https://downloads.mongodb.com/compass/mongodb-mongosh_1.6.0_amd64.deb \
  && dpkg -i mongodb-mongosh_1.6.0_amd64.deb

RUN cd /home && wget https://downloads.mongodb.com/compass/mongodb-compass_1.33.1_amd64.deb \
  && dpkg -i mongodb-compass_1.33.1_amd64.deb

RUN echo "#ADDITIONAL COMMANDS" > ~/.bashrc \
  && echo "#DATABASES" > ~/.bashrc \
  && echo "mongod --dbpath /var/lib/mongo --logpath /var/log/mongodb/mongod.log --fork" > ~/.bashrc

COPY .bash_aliases /root/.bash_aliases

CMD ["bash"]
