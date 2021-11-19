#------------------------------------------------------------------------------
# 1st stage
# -----------------------------------------------------------------------------
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

FROM scratch AS bootstrap
COPY --from=0 /root.x86_64 /

###############################################################################

FROM bootstrap AS build

# pacman mirrors
RUN cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bck
RUN cat /etc/pacman.d/mirrorlist.bck | awk -F# '{ print $2 }' > /etc/pacman.d/mirrorlist

# pacman configuration
RUN pacman -Syu --noconfirm
RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syu --noconfirm reflector
RUN reflector --latest 16 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# clone archstrap-etc
RUN pacman -Syu --noconfirm git
WORKDIR /etc
RUN git clone --no-checkout https://github.com/sebastianlach/archstrap-etc.git
RUN mv archstrap-etc/.git .git && rmdir archstrap-etc

# install packages from pkglist
RUN git checkout HEAD /etc/pacman.d/pkglist
RUN awk -F'[/ ]' '! /^local\// { print $2 }' /etc/pacman.d/pkglist | \
    xargs pacman -Sy --noconfirm && pacman -Scc --noconfirm

# add user
ARG user_login=guest
RUN useradd -m -g users -G wheel,docker -s /bin/zsh ${user_login}
USER ${user_login}
WORKDIR /home/${user_login}
RUN git clone --no-checkout https://github.com/sebastianlach/archstrap-home.git
RUN mv archstrap-home/.git .git && \
    rmdir archstrap-home && \
    git reset --hard HEAD && \
    git submodule update --init --recursive

CMD ["zsh"]
