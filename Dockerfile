FROM scratch
MAINTAINER root@slach.eu

ARG archlinux_bootstrap_url
ADD ${archlinux_bootstrap_url} .

COPY busybox ./busybox

CMD ["./busybox", "sh"]
