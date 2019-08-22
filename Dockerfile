FROM ubuntu:19.04

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies

RUN \
       export http_proxy=$proxy \
    && export https_proxy=$http_proxy \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
	openssh-client \
	openssh-server \
        zsh \
        sudo \
        higan \
        fceux \
        pulseaudio \
        curl \
        wget \
        xdg-utils \
        libpango1.0-0 \
        fonts-liberation \
        vim \
        tmux \
        supervisor \
        i3 \
        docker.io \
        libxft-dev \
        terminator \
        man \
        git \
        clang \
        scons \
        libsdl2-dev \
        libsdl2-image-dev \
        libsdl2-ttf-dev \
        libsdl1.2-dev \
        libboost-all-dev \
        x11-utils \
        x11-xkb-utils \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && apt-get auto-remove -y 

ARG version
ARG proxy
ARG email
ARG username
ARG password

LABEL Name="$username" Version="$version" \
      Maintainer="$email"

ENV DEBIAN_FRONTEND=noninteractive

# SSH and NX.
EXPOSE 22
EXPOSE 4000

# Copy the files into the right places.
COPY cbin/ /cbin/

# Setup Developer Environment
RUN \
       addgroup dev \
    && echo '%dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && useradd -s /usr/local/bin/xonsh -G dev devusr \
    && echo "devusr:$password" | /usr/sbin/chpasswd \
    && apt-get install python3-pip -y
RUN \
       pip3 install \
        flask \
        connexion \
        xonsh \
    && chmod -R +x /cbin

WORKDIR /home/devusr
RUN \
       mkdir /data \
    && chmod 777 /data \
    && ln -s /data /home/devusr/work \
    && cd /home/devusr \
    && mkdir .ssh \
    && chown devusr.dev .ssh \
    && chmod 700 .ssh \
    && chown -R devusr.dev /home/devusr

COPY etc/motd /etc/motd
COPY etc/supervisor /etc/supervisor
COPY devusr /home/devusr/
COPY readmes /home/devusr/readmes
USER root
RUN \
       chown -R devusr /home/devusr \
    && chmod o+w /home/devusr \
    && ln -fsv $(which vim) $(which vi) \
    && sed -i s%SED_PROXY%$proxy% /home/devusr/.xonshrc \
    && sed -i s%SED_NAME%$username% /home/devusr/.gitconfig \
    && sed -i s%SED_EMAIL%$email% /home/devusr/.gitconfig \
    && sed -i s%SED_EMAIL%$email% /home/devusr/.xonshrc

# Force user back to root so s6 can run initd processes
ENTRYPOINT ["/init", "/cbin/exec-cmd"]

# Font related.
COPY inconsolata-g.ttf /tmp/onyx/custom_fonts/inconsolata-g.ttf
RUN ln -s /tmp/onyx /usr/share/fonts/fontfiles \
    && fc-cache -fv

# Install nomachine, change password and username to whatever you want here
# Goto https://www.nomachine.com/download/download&id=10 and change for the latest NOMACHINE_PACKAGE_NAME and MD5 shown in that link to get the latest version.
COPY nomachine_6.7.6_11_amd64.deb /tmp/nomachine.deb
ENV NOMACHINE_MD5 4d94be64f52b4b5d726da7d2610feeaa
RUN echo "${NOMACHINE_MD5} */tmp/nomachine.deb" | md5sum -c - \
    && dpkg -i /tmp/nomachine.deb

ADD nxserver.sh /opt/nxserver.sh
RUN sed -i -e s%__USER__%$username% /opt/nxserver.sh
RUN sed -i -e s%__PASSWORD__%$password% /opt/nxserver.sh

# Suckless terminal. libxft-dev was already installed above.
COPY st /tmp/suckless/st
RUN cd /tmp/suckless/st/st-patched && make install

# NES emulator related.
COPY bjne-codebase.tar /opt/bjne-codebase.tar
COPY laines-codebase.tar /opt/laines-codebase.tar
RUN mkdir -p /opt/nes \
    && cd /opt/nes \
    && mv /opt/laines-codebase.tar /opt/nes/laines-codebase.tar \
    && tar -xvf laines-codebase.tar \
    && cd /opt/nes/LaiNES-codebase \
    && scons \
    && cd /opt/nes \
    && mv /opt/bjne-codebase.tar /opt/nes/bjne-codebase.tar \
    && tar -xvf bjne-codebase.tar \
    && cd /opt/nes/bjne-codebase \
    && scons

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN mkdir /run/sshd
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
ENTRYPOINT ["supervisord"]
