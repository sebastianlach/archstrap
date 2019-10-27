# -----------------------------------------------------------------------------
# 1st stage
# -----------------------------------------------------------------------------
FROM alpine as bootstrap
MAINTAINER root@slach.eu
ARG archlinux_mirror_url=https://mirror.rackspace.com/archlinux
ARG archlinux_bootstrap_filename=archlinux-bootstrap-2019.10.01-x86_64.tar.gz
ARG archlinux_bootstrap_uri=iso/2019.10.01/${archlinux_bootstrap_filename}
ARG archlinux_bootstrap_url=${archlinux_mirror_url}/${archlinux_bootstrap_uri}

# install required packages
RUN apk add --no-cache gnupg

# download archlinux bootstrap
RUN wget -O ${archlinux_bootstrap_filename}.sig ${archlinux_bootstrap_url}.sig
RUN wget -O ${archlinux_bootstrap_filename} ${archlinux_bootstrap_url}

# verify archlinux bootstrap signature
COPY key /root/key
RUN gpg --import /root/key/*.gpg
RUN gpg --keyserver-options auto-key-retrieve --verify ${archlinux_bootstrap_filename}.sig ${archlinux_bootstrap_filename}

# verify checksums
RUN md5sum ${archlinux_bootstrap_filename}
RUN sha1sum ${archlinux_bootstrap_filename}

# extract archlinux bootstrap archive
RUN tar zxf ${archlinux_bootstrap_filename}


# -----------------------------------------------------------------------------
# 2nd stage
# -----------------------------------------------------------------------------
FROM scratch
MAINTAINER root@slach.eu
ARG user_login=archstrap

# populate filesystem from bootstrap
COPY --from=bootstrap /root.x86_64 .

# pacman mirrors
RUN cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bck
RUN cat /etc/pacman.d/mirrorlist.bck | awk -F# '{ print $2 }' > /etc/pacman.d/mirrorlist

# pacman configuration
RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syu --noconfirm && pacman -Sy --noconfirm git reflector
RUN reflector --latest 16 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# clone archstrap-etc
WORKDIR /etc
RUN git clone --no-checkout https://github.com/sebastianlach/archstrap-etc.git
RUN mv archstrap-etc/.git .git && rmdir archstrap-etc

# install packages from pkglist
RUN git checkout HEAD /etc/pacman.d/pkglist
RUN awk -F'[/ ]' '! /^local\// { print $2 }' /etc/pacman.d/pkglist | \
    xargs pacman -Sy --noconfirm

# add user
RUN useradd -m -g users -G wheel,docker -s /bin/zsh ${user_login}
USER ${user_login}
WORKDIR /home/${user_login}
RUN git clone --no-checkout https://github.com/sebastianlach/archstrap-home.git
RUN mv archstrap-home/.git .git && \
    rmdir archstrap-home && \
    git reset --hard HEAD && \
    git submodule update --init --recursive

CMD ["zsh"]
