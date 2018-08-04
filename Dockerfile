# This Dockerfile is used to build an headles vnc image based on Ubuntu

FROM ubuntu:16.04

MAINTAINER Daniel Becker "dbecker.fl@gmail.com"
ENV REFRESHED_AT 2018-08-02

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/cs2110 \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/cs2110/install \
    NO_VNC_HOME=/cs2110/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=cs2110rocks \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

### Add all install scripts for further steps
ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/ubuntu/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server, noVNC, chrome, and xfce
RUN $INST_SCRIPTS/tigervnc.sh && \
    $INST_SCRIPTS/no_vnc.sh && \
    $INST_SCRIPTS/chrome.sh && \
    $INST_SCRIPTS/xfce_ui.sh

ADD ./src/common/xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME


### Install Complx
WORKDIR /complx
ADD ./src/common/complx/ .
RUN ./install.sh && rm -rf *
WORKDIR $HOME
USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]