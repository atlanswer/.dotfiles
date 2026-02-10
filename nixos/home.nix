{ lib, config, pkgs, ...}: {
  home = {
    username = "atlanswer";
    homeDirectory = "/home/atlanswer";

    stateVersion = "26.05";

    packages = with pkgs; [
      # Programming languages
      clang
      clang-tools
      libclang.lib
      nodejs_latest
      rustc
      cargo
      cargo-cache
      cargo-update
      # Dev tools
      ripgrep
      fzf
      eza
      bat
      lua-language-server
      stylua
      # tree-sitter
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
      stow
    ];

    sessionVariables = {
      LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    };
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
    envExtra = "setopt no_global_rcs";
    initContent = import ./zshrc.nix { inherit lib; };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
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
