FROM centos:7

ARG USER=deus

RUN yum install -y epel-release && \ 
    yum install -y openssh-server \
                   openssh-clients \
                   openssl-libs \
                   passwd \
                   sudo \
		   less \
                   iproute \
		   iputils \
		   wget \
    && systemctl enable sshd && \
    yum clean all

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
   systemd-tmpfiles-setup.service ] || rm -f $i; done); \
   rm -f /lib/systemd/system/multi-user.target.wants/*;\
   rm -f /etc/systemd/system/*.wants/*;\
   rm -f /lib/systemd/system/local-fs.target.wants/*; \
   rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
   rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
   rm -f /lib/systemd/system/basic.target.wants/*;\
   rm -f /lib/systemd/system/anaconda.target.wants/*;\
   rm -f /lib/systemd/system/*.wants/*update-utmp*;

RUN useradd -s /bin/bash ${USER} && \
    echo ${USER} | passwd ${USER} --stdin && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}
WORKDIR /home/${USER}
RUN mkdir /home/${USER}/.ssh && \
    chown -R ${USER}: /home/${USER}/.ssh/ && \
    chmod -R 600 /home/${USER}/.ssh/ 
#&& chmod a+x /home/${USER}/.ssh/

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US


EXPOSE 22
USER ${USER}

# graceful shutdown the container
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]
