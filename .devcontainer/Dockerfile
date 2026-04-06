FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        git \
        less \
        procps \
        software-properties-common \
        sudo \
        unzip \
        zip \
    && add-apt-repository -y ppa:dotnet/backports \
    && apt-get update \
    && apt-get install -y --no-install-recommends dotnet-sdk-10.0 \
    && rm -rf /var/lib/apt/lists/*

RUN if ! getent group vscode >/dev/null; then groupadd vscode; fi \
    && if ! id -u vscode >/dev/null 2>&1; then useradd --gid vscode --create-home --home-dir /home/vscode --shell /bin/bash vscode; fi \
    && mkdir -p /home/vscode \
    && chown -R vscode:vscode /home/vscode \
    && echo "vscode ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/90-vscode \
    && chmod 0440 /etc/sudoers.d/90-vscode

COPY init-home.sh /usr/local/bin/init-home.sh

RUN chmod 0755 /usr/local/bin/init-home.sh

ENTRYPOINT ["/usr/local/bin/init-home.sh"]
CMD ["sleep", "infinity"]
