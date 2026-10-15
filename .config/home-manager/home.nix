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
      alloy6
      awscli2
      bat
      bun
      curl
      dafny
      delta
      deno
      dust
      elan
      fd
      fre
      git
      go_latest
      graphviz
      gron
      hyperfine
      jjui
      jo
      jq
      jujutsu
      just
      mermaid-cli
      mise
      neovim
      nodejs_26
      nushell
      quint
      ripgrep
      shellcheck
      shfmt
      terraform
      tmux
      tree
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

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases = {
        co = "pr checkout";
        cl = "repo clone";
        clp = "repo clone $1 -- --filter=blob:none";
        clps = "repo clone $1 -- --filter=blob:none --sparse";
        cr = "repo create";
        il = "issue list";
        cod = "pr checkout --detach";
        al = "alias list";
        openr = "repo view -w";
        openi = "issue view -w";
        openp = "pr view -w";
        sync = ''!gh repo sync $(git config --get remote.origin.url | \grep -oP "(?<=/)[^/.]+?/[^.]+")'';
      };
    };
    extensions = with pkgs; [
    ];
  };
}
