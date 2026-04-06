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

RUN \
    # The repo is bind-mounted from a host user that owns files as 1000:1000.
    # Ubuntu 24.04 already ships an `ubuntu` user at 1000:1000, so remove it and
    # recreate `vscode` with that identity to keep the mounted workspace writable.
    if getent passwd ubuntu >/dev/null && [ "$(id -u ubuntu)" = "1000" ]; then userdel -r ubuntu; fi \
    && if getent group 1000 >/dev/null; then groupdel "$(getent group 1000 | cut -d: -f1)"; fi \
    && groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 --create-home --home-dir /home/vscode --shell /bin/bash vscode \
    && mkdir -p /home/vscode \
    && chown -R vscode:vscode /home/vscode \
    && echo "vscode ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/90-vscode \
    && chmod 0440 /etc/sudoers.d/90-vscode

COPY init-home.sh /usr/local/bin/init-home.sh

RUN chmod 0755 /usr/local/bin/init-home.sh

ENTRYPOINT ["/usr/local/bin/init-home.sh"]
CMD ["sleep", "infinity"]
