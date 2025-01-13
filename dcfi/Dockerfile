FROM debian:bookworm-slim

RUN apt update && apt install -y openssh-server nano

RUN mkdir -p /run/sshd && \
    echo "root:password" | chpasswd && \
    sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    systemctl enable ssh || true

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]