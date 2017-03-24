FROM centos:7.2.1511

RUN yum -y install \
    git \
    # Docker daemon won't start without `iptables` installed
    iptables-services \
    # Used for a variety of simple tests for port forwarding/publishing
    nmap-ncat net-tools \
    # Allow `dock-user` to escalate privileges if necessary
    sudo \
    # Allow us to run using OverlayFS file system
    yum-plugin-ovl \
    && yum clean all

# Install Docker daemon so we can run Docker inside the Dock container
RUN curl -L https://get.docker.com/builds/Linux/x86_64/docker-1.12.3.tgz \
    | tar -xzf - -C /usr/bin --strip-components=1

# Install docker-compose so we can run the docker-compose tool inside the Dock container
RUN curl -L https://github.com/docker/compose/releases/download/1.11.2/run.sh > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install Bats testing framework
RUN mkdir -p /src \
    && git clone --depth=1 https://github.com/sstephenson/bats.git /src/bats \
    && cd /src/bats \
    && ./install.sh /usr/local \
    && rm -rf /src

# Create a non-root user with sudo privileges
RUN useradd dock-user \
    && echo "%dock-user  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dock-user \
    && groupadd --non-unique -g $(grep dock-user /etc/group | cut -d: -f3) docker
USER dock-user
