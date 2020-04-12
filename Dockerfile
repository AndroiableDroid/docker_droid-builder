FROM ubuntu:bionic

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Android ROM Builder" \
      org.label-schema.description="Ubuntu Latest Bionic LTS Image For Building Android ROMs/TWRPs" \
      org.label-schema.url="https://rokibhasansagar.github.io/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vendor="Rokib Hasan Sagar" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

LABEL maintainer="fr3akyphantom <rokibhasansagar2014@outlook.com>"

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    JAVA_OPTS=" -Xmx3840m " \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk-amd64 \
    PATH=~/bin:/usr/local/bin:/home/builder/bin:$PATH \
    USE_CCACHE=1 \
    CCACHE_COMPRESS=1 \
    CCACHE_COMPRESSLEVEL=8 \
    CCACHE_DIR=/srv/ccache

RUN sed 's/main$/main universe/' /etc/apt/sources.list 1>/dev/null

RUN apt-get -q -y update \
    && apt-get -q -y install \
        apt-utils apt-transport-https \
        curl wget wput git build-essential squashfs-tools automake autoconf binutils \
        software-properties-common coreutils util-linux gawk xterm rename bc tree dos2unix sshpass sudo \
        android-sdk-platform-tools android-tools-adb android-tools-adbd android-tools-fastboot \
        openjdk-8-jdk maven nodejs python-dev python3-dev jq \
        file screen axel bison clang cmake rsync flex gnupg gperf pngcrush schedtool bsdmainutils \
        zip unzip lzop zlib1g-dev xz-utils pxz pixz zstd libzstd1-dev libb2-dev patchutils \
        gcc gcc-multilib g++ g++-multilib libxml2 libxml2-utils xsltproc expat re2c \
        ncurses-bin libncurses5-dev lib32ncurses5-dev libreadline-gplv2-dev lib32z1-dev libsdl1.2-dev libwxgtk3.0-dev \
    && apt-get -y purge openjdk-11-jre-headless \
    && apt-get -y clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
    && dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot \
    && chmod u+s /usr/bin/screen \
    && chmod 755 /var/run/screen

RUN mkdir -p /home/builder \
    && useradd --no-create-home builder \
    && rsync -a /etc/skel/ /home/builder/ \
    && chown -R builder:builder /home/builder \
    && echo "builder ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

RUN mkdir /home/builder/bin \
    && curl -L https://github.com/GerritCodeReview/git-repo/raw/stable/repo -o /home/builder/bin/repo \
    && curl -s https://api.github.com/repos/tcnksm/ghr/releases/latest | grep "browser_download_url" | grep "amd64.tar.gz" | cut -d '"' -f 4 | wget -qi - \
    && tar -xzf ghr_*_amd64.tar.gz \
    && cp ghr_*_amd64/ghr /home/builder/bin/ \
    && rm -rf ghr_* \
    && chmod a+rx /home/builder/bin/repo \
    && chmod a+x /home/builder/bin/ghr

RUN echo "Setting latest official make, ninja & ccache" \
    && mkdir -p extra \
    && cd extra \
    && wget -q https://ftp.gnu.org/gnu/make/make-4.3.tar.gz \
    && tar xzf make-4.3.tar.gz \
    && cd make-*/ \
    && ./configure \
    && bash ./build.sh 1>/dev/null \
    && sudo install ./make /usr/local/bin/make \
    && cd .. \
    && git clone https://github.com/ninja-build/ninja.git \
    && cd ninja \
    && git checkout -q v1.10.0 \
    && ./configure.py --bootstrap \
    && sudo install ./ninja /usr/local/bin/ninja \
    && cd .. \
    && git clone https://github.com/ccache/ccache.git \
    && cd ccache \
    && git checkout -q v3.7.9 \
    && ./autogen.sh \
    && ./configure --disable-man \
    && make -j16 \
    && sudo make install \
    && cd ../.. \
    && rm -rf extra

COPY android-env-vars.sh /etc/android-env-vars.sh

RUN chmod a+x /etc/android-env-vars.sh \
    && echo "source /etc/android-env-vars.sh" >> /etc/bash.bashrc

VOLUME [/home/builder]
VOLUME [/srv/ccache]

RUN CCACHE_DIR=/srv/ccache ccache -M 8G
