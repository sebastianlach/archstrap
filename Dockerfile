# bootstrap build stage
FROM busybox as bootstrap
MAINTAINER root@slach.eu
ARG archlinux_bootstrap_url=http://mirrors.edge.kernel.org/archlinux/iso/2018.12.01/archlinux-bootstrap-2018.12.01-x86_64.tar.gz
ADD ${archlinux_bootstrap_url} archlinux-bootstrap-x86_64.tar.gz
RUN tar zxf archlinux-bootstrap-x86_64.tar.gz


# image build stage
FROM scratch
MAINTAINER root@slach.eu
COPY --from=bootstrap /root.x86_64 .
CMD ["bash"]
