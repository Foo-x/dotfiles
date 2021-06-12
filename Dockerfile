FROM ubuntu:20.04
LABEL Name=dotfiles Version=0.0.1

ARG USER=foo
ARG HOME=/home/${USER}
ARG WORKSPACE=/workspace
ARG DOTFILES=${HOME}/dotfiles

RUN useradd -s /bin/bash -m ${USER} && \
    apt update && \
    apt install -y curl git language-pack-ja vim wget && \
    mkdir ${DOTFILES} && \
    chown -R ${USER}:${USER} ${HOME}

USER ${USER}
WORKDIR ${HOME}

COPY .aliases \
     .bashrc \
     .exports \
     .git-completion \
     .gitconfig \
     .inputrc \
     .vimrc* \
     fetch_git_completions.sh \
     ${DOTFILES}

RUN echo ". ~/dotfiles/.bashrc" >> .bashrc && \
    echo ". ~/dotfiles/.aliases" >> .bashrc && \
    echo ". ~/dotfiles/.exports" >> .bashrc && \
    echo ". ~/dotfiles/.git-completion" >> .bashrc && \
    printf "[include]\n\tpath = ~/dotfiles/.gitconfig" >> .gitconfig && \
    echo '$include ~/dotfiles/.inputrc' >> .inputrc && \
    echo "source ~/dotfiles/.vimrc" >> .vimrc && \
    cd dotfiles && \
    ./fetch_git_completions.sh

WORKDIR ${WORKSPACE}
