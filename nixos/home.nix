{ config, pkgs, ...}: {
  home = {
    username = "atlanswer";
    homeDirectory = "/home/atlanswer";

    stateVersion = "26.05";

    packages = with pkgs; [
      # Programming languages
      nodejs_latest
      rustup
      # Dev tools
      ripgrep
      fzf
      eza
      zoxide
      bat
      # tree-sitter
      yazi
      fd
      tealdeer
      # Utilities
      btop
      fastfetch
      # Core pkgs
      curl
      wget
      file
      tree
      jq
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.bun = {
    enable = true;
    settings = {
      install.linker = "isolated";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableVteIntegration = true;
    history = {
      append = true;
      expireDuplicatesFirst = true;
    };
    initContent = lib.mkOrder 500 ''
      ZIM_CONFIG_FILE=~/.config/zsh/zimrc
      ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
    '';
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
