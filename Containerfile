FROM ghcr.io/gzsoares/fedora-bootc-nvidia-driver:latest

RUN dnf5 install gnome-shell --setopt=tsflags=nodocs --setopt=install_weak_deps=False -y && \
    dnf5 clean all && \
    rm -rfv /var/lib/dnf/* /var/log/* /tmp/* /var/tmp/* 

COPY pacotes_necessarios pacotes_desktop ./
RUN grep -v '^#' pacotes_necessarios | tr '\n' ' ' | xargs dnf5 install --setopt=tsflags=nodocs -y && \
    grep -v '^#' pacotes_desktop | tr '\n' ' ' | xargs dnf5 install --setopt=tsflags=nodocs -y && \
    dnf5 clean all && \
    rm -rfv /var/lib/dnf/* /var/log/* /tmp/* /var/tmp/*

COPY locale.conf post-install.sh post-install.service vconsole.conf zram-generator.conf libvirt.conf /tmp/sysconfig/
RUN mkdir -vp /var/opt /var/usrlocal /etc/sysusers.d /usr/lib/bootc/kargs.d /etc/modprobe.d && \
    rm -rfv /opt /usr/local && \
    ln -vs /var/opt /opt && \
    ln -vs /var/usrlocal /usr/local && \
    mv -v /tmp/sysconfig/libvirt.conf /etc/sysusers.d/ && \
    mv -v /tmp/sysconfig/zram-generator.conf /etc/systemd/ && \
    mv -v /tmp/sysconfig/vconsole.conf /etc/vconsole.conf && \
    mv -v /tmp/sysconfig/locale.conf /etc/locale.conf && \
    mv -v /tmp/sysconfig/post-install.sh /usr/bin/post-install.sh && \
    mv -v /tmp/sysconfig/post-install.service /usr/lib/systemd/system/post-install.service && \
    chmod +x /usr/bin/post-install.sh && \
    systemctl enable thermald.service post-install.service libvirtd.service spice-vdagentd.service && \
    systemctl mask systemd-remount-fs.service akmods-keygen@akmods-keygen.service && \
    rm -rf /tmp/sysconfig /var/cache/* /var/lib/dnf/* /var/log/* /tmp/* /var/tmp/*

RUN bootc container lint
