{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  androidSdkPath = "${config.home.homeDirectory}/Library/Android/sdk";
in
{
  imports = [
    inputs.android-nixpkgs.hmModule
  ];

  android-sdk = {
    enable = true;
    path = androidSdkPath;
    packages =
      sdk: with sdk; [
        cmdline-tools-latest
        platform-tools
        platforms-android-36
        sources-android-36
        build-tools-35-0-0
        build-tools-36-1-0
        ndk-27-1-12297006
        cmake-3-22-1
      ];
  };

  home = {
    username = "atlanswer";
    homeDirectory = lib.mkForce /Users/atlanswer;
  };

  home.packages = with pkgs; [
    # Android
    zulu17
    gradle
    watchman
    # iOS
    cocoapods

    nodejs_latest
    rustc
    cargo
    cargo-cache
    cargo-update

    # ripgrep # required by codex in homebrew
    fzf
    eza
    bat
    fd
    dust
    scc
    tree-sitter
    lua-language-server
    stylua
    nixd
    nixfmt # statix deadnix
    zimfw

    localsend
    typst

    tealdeer
    btop
    fastfetch
    curl
    wget
    file
    tree
    jq
    stow
    iproute2mac
    rar

    mihomo
  ];

  home.sessionVariables = {
    # Android
    JAVA_HOME = "${pkgs.zulu17}";
    # ANDROID_HOME = androidSdkPath;
    # ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk";
  };

  home.sessionPath = [
    # "${androidSdk}/libexec/android-sdk/platform-tools"
    # "${androidSdk}/libexec/android-sdk/cmdline-tools/latest/bin"
    # "${androidSdk}/libexec/android-sdk/build-tools/<>"
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    sideloadInitLua = true;
  };

  programs.bun = {
    enable = true;
    settings = {
      install = {
        linker = "isolated";
        globalStore = true;
        minimumReleaseAge = 259200;
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableVteIntegration = true;
    defaultKeymap = "viins";
    history = {
      append = true;
      expireDuplicatesFirst = true;
    };
    envExtra = "setopt no_global_rcs";
    initContent = import ./zshrc.nix { inherit lib; };
  };

  programs.opencode = {
    enable = true;
    settings = {
      autoupdate = false;
      share = "disabled";
      snapshot = false;
      model = "openai/gpt-5.5";
    };
    tui = {
      scroll_acceleration.enabled = true;
      diff_style = "auto";
    };
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

  programs.uv = {
    enable = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "atlanswer";
      user.email = "i@atlanswer.com";
      working-copy.eol-conversion = "input";
      git.sign-on-push = true;
      signing.backend = "ssh";
      signing.key = "~/.ssh/id_ecdsa_sk_rk";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "atlanswer";
      user.email = "i@atlanswer.com";
      user.signingKey = "~/.ssh/id_ecdsa_sk_rk";
      core.autocrlf = "input";
      init.defaultBranch = "main";
      color.ui = true;
      pull.rebase = false;
      pull.ff = "only";
      fetch.rebase = false;
      fetch.ff = "only";
      fetch.prune = true;
      push.autoSetupRemote = true;
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    maintenance.enable = true;
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    jujutsu.enable = false;
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = "high-quality";
      cscale = "catmull_rom";
      deband = true;
      icc-profile-auto = true;
      blend-subtitles = "video";
      audio-file-auto = "fuzzy";
      sub-auto = "fuzzy";
      target-colorspace-hint = true;
      hwdec = "auto";
      keep-open = true;
      save-position-on-quit = true;
      watch-later-options = "start,vid,aid,sid";
    };
  };

  launchd = {
    agents = {
      mihomo = {
        enable = true;
        config = {
          Label = "mihomo-service";
          ProgramArguments = [
            "${pkgs.mihomo}/bin/mihomo"
            "-d"
            "${config.home.homeDirectory}/.config/mihomo"
          ];
          ProcessType = "Standard";
          KeepAlive = true;
        };
      };
    };
  };

  services.ssh-agent = {
    enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FiraCode Nerd Font" ];
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
