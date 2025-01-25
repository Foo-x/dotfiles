{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  user = builtins.getEnv "USER";
  home = builtins.getEnv "HOME";

  # deno 2.1.6 can't use for denops
  pkgs_deno_2_1_5 = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/archive/58d56529cfabde4a6a11293eb3078dd868d821d2.tar.gz") {};
  deno = pkgs_deno_2_1_5.deno;
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = user;
    homeDirectory = home;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    packages = with pkgs; [
      aichat
      awscli2
      bat
      bun
      curl
      delta
      deno
      dust
      fd
      fre
      gh
      git
      gitui
      graphviz
      gron
      hyperfine
      jq
      jujutsu
      just
      mise
      neovim
      nodejs_22
      python313
      ripgrep
      terraform
      tmux
      typos
      unison
      universal-ctags
      vim
      vscode-langservers-extracted
      watchexec
      zoxide
    ];
  };

  programs.home-manager.enable = true;
}
