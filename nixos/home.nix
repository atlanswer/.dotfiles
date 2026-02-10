{ config, pkgs, ...}: {
  home = {
    username = "atlanswer";
    homeDirectory = "/home/atlanswer";

    stateVersion = "26.05";

    packages = with pkgs; [
      neovim

      ripgrep
      fzf
      eza
      zoxide
      bat
      yazi
      tealdeer

      btop
      fastfetch

      curl
      wget
      file
      tree
      jq
    ];
  };

  programs.zsh = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "atlanswer";
      user.email = "i@atlanswer.com";
      init.defaultBranch = "main";
      gpg.ssh.defaultKeyCommand = "ssh-add -L";
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    maintenance.enable = true;
  };
}
