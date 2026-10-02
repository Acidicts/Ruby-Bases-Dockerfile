FROM ruby:4.0.7-bookworm

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# One apt layer: dev utilities, build deps for native gems, and sudo
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    curl \
    git \
    openssh-client \
    less \
    iproute2 \
    procps \
    gnupg2 \
    build-essential \
    autoconf \
    bison \
    gawk \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libgdbm-dev \
    libncurses-dev \
    libffi-dev \
    libgmp-dev \
    libsqlite3-dev \
    liblzma-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libtool \
    pkg-config \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Non-root user matching what devcontainers expect
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# The official image sets GEM_HOME=/usr/local/bundle; let the non-root user write to it
RUN chown -R $USERNAME:$USERNAME "$GEM_HOME"

USER $USERNAME

# Bundler 4.x already ships with Ruby 4.0, so only Rails needs installing
RUN gem install rails --no-document

# Sanity check
RUN ruby --version && rails --version && bundler --version
