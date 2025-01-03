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
      hyperfine
      jq
      jujutsu
      just
      neovim
      nodejs_22
      python313
      ripgrep
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
