# bootstrap build stage
FROM alpine as bootstrap
MAINTAINER root@slach.eu
ARG archlinux_bootstrap_url=http://mirrors.edge.kernel.org/archlinux/iso/2018.12.01/archlinux-bootstrap-2018.12.01-x86_64.tar.gz
RUN apk add --no-cache gnupg
RUN wget -O archlinux-bootstrap-x86_64.tar.gz.sig ${archlinux_bootstrap_url}.sig
RUN wget -O archlinux-bootstrap-x86_64.tar.gz ${archlinux_bootstrap_url}
RUN gpg --keyserver pgp.mit.edu --recv-keys 4AA4767BBC9C4B1D18AE28B77F2D434B9741E8AC
RUN gpg --verify archlinux-bootstrap-x86_64.tar.gz.sig archlinux-bootstrap-x86_64.tar.gz
RUN tar zxf archlinux-bootstrap-x86_64.tar.gz


# image build stage
FROM scratch
MAINTAINER root@slach.eu
COPY --from=bootstrap /root.x86_64 .

RUN cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bck
RUN cat /etc/pacman.d/mirrorlist.bck | awk -F# '{ print $2 }' > /etc/pacman.d/mirrorlist

RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm git openssh

WORKDIR /etc
RUN git clone --no-checkout https://github.com/sebastianlach/archstrap-etc.git
RUN mv archstrap-etc/.git .git && rmdir archstrap-etc && git reset --hard HEAD

# TODO: check archstrap-etc here

RUN egrep -Ev '^local/' /etc/pacman.d/pkglist | \
    awk -F'[/ ]' '{ print $2 }' | \
    xargs pacman -Sy --noconfirm

CMD ["bash"]
