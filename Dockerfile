FROM ubuntu:24.04

RUN apt-get update && apt-get install -y python3 python3-pip python3-venv bash curl wget vim jq pipx openssl openssh-client sshpass netcat-openbsd && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf $(python3 -c "import sysconfig; print(sysconfig.get_path(\"stdlib\"))")/EXTERNALLY-MANAGED

RUN pipx install --include-deps ansible && \
    pipx ensurepath
ENV PATH=${PATH}:/root/.local/bin

