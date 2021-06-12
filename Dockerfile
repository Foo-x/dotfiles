# fetch
FROM alpine as fetch
WORKDIR /ws

COPY fetch_git_completions.sh .
RUN sh fetch_git_completions.sh


# base
FROM ubuntu:20.04

ARG USER=foo
ARG HOME=/home/${USER}
ARG WORKSPACE=/workspace
ARG DOTFILES=${HOME}/dotfiles

RUN apt update \
    && apt install -y \
    curl \
    git \
    language-pack-ja \
    vim \
    wget \
    && apt install --no-install-recommends -y \
    python3.8 \
    python3-pip \
    python3.8-dev \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -s /bin/bash -m ${USER} \
    && mkdir ${DOTFILES} \
    && chown -R ${USER}:${USER} ${HOME}

USER ${USER}
WORKDIR ${HOME}

COPY .aliases \
    .bashrc \
    .exports \
    .git-completion \
    .gitconfig \
    .inputrc \
    .vimrc* \
    ${DOTFILES}
COPY --from=fetch /ws/git* /ws/hub* ${DOTFILES}

RUN echo ". ~/dotfiles/.bashrc" >> .bashrc \
    && echo ". ~/dotfiles/.aliases" >> .bashrc \
    && echo ". ~/dotfiles/.exports" >> .bashrc \
    && echo ". ~/dotfiles/.git-completion" >> .bashrc \
    && printf "[include]\n\tpath = ~/dotfiles/.gitconfig" >> .gitconfig \
    && echo '$include ~/dotfiles/.inputrc' >> .inputrc \
    && echo "source ~/dotfiles/.vimrc" >> .vimrc

WORKDIR ${WORKSPACE}
