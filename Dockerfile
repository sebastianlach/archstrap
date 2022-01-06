###############################################################################
### 1st stage
###############################################################################
FROM alpine AS builder
MAINTAINER root@slach.eu
ARG archlinux_mirror_url=https://mirror.rackspace.com/archlinux

# install required packages
RUN apk add --no-cache gnupg

# discover latest bootrap archive
RUN wget -q -O - ${archlinux_mirror_url}/iso/latest/\
    | egrep -Eo 'archlinux-bootstrap-[^<>"]*'\
    | sort -n | head -n1\
    | xargs -I% echo ${archlinux_mirror_url}/iso/latest/% > bootstrap.url

# download archlinux bootstrap
RUN xargs -I% wget -O bootstrap.tar.gz % < bootstrap.url
RUN xargs -I% wget -O bootstrap.tar.gz.sig %.sig < bootstrap.url

# verify archlinux bootstrap signature
RUN gpg --keyserver-options auto-key-retrieve\
        --verify bootstrap.tar.gz.sig\
        bootstrap.tar.gz

# verify checksums
RUN md5sum bootstrap.tar.gz
RUN sha1sum bootstrap.tar.gz

# extract files
RUN tar -C / -zxf bootstrap.tar.gz

###############################################################################
### 2nd stage
###############################################################################
FROM scratch AS bootstrap
COPY --from=0 /root.x86_64 /

###############################################################################
### 3rd stage
###############################################################################
FROM bootstrap AS build

# pacman mirrors
RUN cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bck
RUN cat /etc/pacman.d/mirrorlist.bck | awk -F# '{ print $2 }' > /etc/pacman.d/mirrorlist

# pacman configuration
ADD etc/pacman.conf /etc/pacman.conf
RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syu --noconfirm reflector git
RUN reflector --latest 16 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# copy subrepositories
WORKDIR /repo
COPY .git /repo/.git
COPY .gitmodules /repo/.gitmodules
COPY etc /repo/etc
COPY home /repo/home

# populate etc
WORKDIR /etc
RUN git clone --no-checkout /repo/etc tmp && mv tmp/.git .git && rm -rf tmp
RUN git reset --hard HEAD

# install packages from pkglist
RUN cat /etc/pacman.d/pkglist | cut -d' ' -f1 | \
    xargs pacman -Sy --noconfirm && \
    pacman -Scc --noconfirm

# systemctl configuration
RUN systemctl enable slim

# configure root
RUN echo 'root:root' | chpasswd

# generate locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# configure default user
ARG login=guest
RUN useradd -m -g users -G wheel,docker -s /bin/zsh ${login}
RUN echo "${login}:${login}" | chpasswd
USER ${login}
WORKDIR /home/${login}
RUN git clone --no-checkout https://github.com/sebastianlach/archstrap-home.git
RUN mv archstrap-home/.git .git && \
    rmdir archstrap-home && \
    git reset --hard HEAD && \
    git submodule update --init --recursive

CMD ["zsh"]
