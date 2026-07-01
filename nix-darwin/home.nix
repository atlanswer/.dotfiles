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
    # inputs.paneru.homeModules.paneru
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
        ndk-27-0-12077973
        ndk-27-1-12297006
        cmake-3-22-1
      ];
  };

  home = {
    username = "atlanswer";
    homeDirectory = lib.mkForce /Users/atlanswer;
  };

  home.packages = with pkgs; [
    zvm
    # Rust
    # rustc
    # cargo-cache
    # cargo-update
    # Dev tools
    # scc
    # dua
    # dust
    # tree-sitter
    # lua-language-server
    # stylua
    nixd
    nixfmt # statix deadnix
    zimfw
    # Core utils
    curl
    file
    rar
    # Proxy
    # mihomo
    # hysteria
  ];

  home.sessionVariables = {
    # Android
    # ANDROID_HOME = androidSdkPath;
    # ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk";
  };

  home.sessionPath = [
    # "${androidSdk}/libexec/android-sdk/platform-tools"
    # "${androidSdk}/libexec/android-sdk/cmdline-tools/latest/bin"
    # "${androidSdk}/libexec/android-sdk/build-tools/<>"
  ];

  programs = {
    mise = {
      enable = false;
      package = null;
      enableZshIntegration = false;
      globalConfig = {
        tools = {
          node = "latest";
        };
      };
    };
    eza = {
      enable = true;
    };
    bat = {
      enable = true;
    };
    btop = {
      enable = true;
      settings = {
        update_ms = 2000;
        vim_keys = true;
        rounded_corners = true;
        color_theme = "Default";
        graph_symbol = "braille";
        theme_background = false;
        truecolor = true;
        terminal_sync = true;
      };
    };
    fzf = {
      enable = true;
      # enableZshIntegration = true; # Managed by zim
      tmux = {
        enableShellIntegration = true;
      };
    };
    fd = {
      enable = true;
    };
    jq = {
      enable = true;
    };
    tealdeer = {
      enable = true;
    };
    cargo = {
      enable = true;
    };
    fastfetch = {
      enable = true;
    };
    difftastic = {
      enable = true;
      git.enable = true;
      jujutsu.enable = false;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      sideloadInitLua = true;
    };
    bun = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        install = {
          linker = "isolated";
          globalStore = true;
          minimumReleaseAge = 259200;
        };
      };
    };
    ghostty = {
      enable = true;
      package = pkgs.ghostty-bin;
      enableZshIntegration = true;
    };
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      mouse = true;
    };
    zsh = {
      enable = true;
      enableCompletion = false;
      enableVteIntegration = true;
      defaultKeymap = "viins";
      history = {
        append = true;
        expireDuplicatesFirst = true;
      };
      envExtra = "setopt no_global_rcs";
      initContent = import ./zshrc.nix { inherit lib pkgs; };
    };
    ripgrep = {
      enable = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };
    uv = {
      enable = true;
    };
    zed-editor = {
      enable = false;
    };
    codex = {
      enable = false;
    };
    opencode = {
      enable = false;
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
      agents = { };
      commands = { };
      skills = { };
      tools = { };
    };
    pi-coding-agent = {
      enable = false;
    };
    t3code = {
      enable = false;
    };
    java = {
      enable = true;
      package = pkgs.zulu17;
    };
    gradle = {
      enable = true;
    };
    jujutsu = {
      enable = true;
      settings = {
        user.name = "atlanswer";
        user.email = "i@atlanswer.com";
        working-copy.eol-conversion = "input";
        git.sign-on-push = true;
        signing.backend = "ssh";
        signing.key = "~/.ssh/id_ed25519.pub";
      };
    };
    git = {
      enable = true;
      settings = {
        user.name = "atlanswer";
        user.email = "i@atlanswer.com";
        user.signingKey = "~/.ssh/id_ed25519.pub";
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
    mpv = {
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
    home-manager = {
      enable = true;
    };
  };

  # launchd = {
  #   agents = {
  #     mihomo = {
  #       enable = true;
  #       config = {
  #         Label = "mihomo-service";
  #         ProgramArguments = [
  #           "${pkgs.mihomo}/bin/mihomo"
  #           "-d"
  #           "${config.home.homeDirectory}/.config/mihomo"
  #         ];
  #         ProcessType = "Standard";
  #         KeepAlive = true;
  #       };
  #     };
  #   };
  # };

  services.ssh-agent = {
    enable = true;
  };

  services.skhd = {
    enable = true;
    config = ''
      # Launch Ghostty
      rcmd - return : open "$HOME/Applications/Home Manager Apps/Ghostty.app"
    '';
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

}
