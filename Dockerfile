FROM debian:trixie

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y sudo python3 python3-pip python3-venv bash curl wget vim jq pipx openssl openssh-client sshpass netcat-openbsd && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf $(python3 -c "import sysconfig; print(sysconfig.get_path(\"stdlib\"))")/EXTERNALLY-MANAGED
RUN pipx install --include-deps ansible && \
    pipx ensurepath
ENV PATH=${PATH}:/root/.local/bin \
    USER=root
RUN ansible-galaxy collection install community.general ansible.posix
COPY group_vars /root/k8s_installer/group_vars
COPY roles /root/k8s_installer/roles
COPY sample_inventory /root/k8s_installer/sample_inventory
COPY ansible.cfg create_cluster.yml /root/k8s_installer
RUN mkdir /root/k8s_installer/vars
WORKDIR /root/k8s_installer
VOLUME /root/k8s_instaler/vars

ENTRYPOINT ["/bin/bash"]
