FROM ubuntu

RUN mkdir /var/fpwork

VOLUME /var/fpwork
VOLUME /usr
VOLUME /home
VOLUME /lib
VOLUME /etc

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y git \
                        g++ \
                        make \
                        build-essential \
                        wget \
                        libgtk-3-dev \
                        lubuntu-desktop \
                        lightdm

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

RUN apt-get install -y cmake pkg-config
RUN apt-get install -y mesa-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev
RUN apt-get install -y libglew-dev libglfw3-dev libglm-dev
RUN apt-get install -y libao-dev libmpg123-dev
RUN apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

RUN cd /home

RUN wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.1/wxWidgets-3.2.1.tar.bz2 \
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

RUN wget https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.gz \
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

CMD service dbus start ; service lightdm start
