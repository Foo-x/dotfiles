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
