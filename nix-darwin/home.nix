{
  lib,
  pkgs,
  ...
}:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "latest";
    platformToolsVersion = "latest";
    platformVersions = [ "36" ];
    includeSources = true;
    buildToolsVersions = [
      # "35.0.0"
      "36.1.0"
    ];
    includeNDK = "if-supported";
    ndkVersions = [
      # "27.0.12077973"
      "27.1.12297006"
    ];
    includeCmake = "if-supported";
    cmakeVersions = [ "3.22.1" ];
    includeEmulator = false;
    toolsVersion = null;
  };
  androidSdk = androidComposition.androidsdk;
in
{
  home = {
    username = "atlanswer";
    homeDirectory = lib.mkForce /Users/atlanswer;
  };

  home.packages = with pkgs; [
    androidSdk
    nodejs_latest
    zvm
    # odin
    go
    ### Rust
    rustc
    cargo-cache
    cargo-update
    ### Toolchain
    gcc-arm-embedded
    # gcc-arm-embedded-13
    clang-tools
    cmake
    ninja
    bear
    ccache
    ### AI
    opencode
    pi-coding-agent
    # llama-cpp
    ### Dev tools
    stylua
    nixd
    nixfmt # statix deadnix
    zimfw
    mbake
    postgresql
    skopeo
    ### Cli
    nixos-rebuild-ng
    scc
    dua
    dust
    xh
    mas
    sops
    age
    ssh-to-age
    ### Others
    (mpv.override { youtubeSupport = false; })
    typst
    ### Core utils
    curl
    wget
    file
    tree
    gnumake
    stow
    rar
    p7zip
    ### Proxy
    # mihomo
    hysteria
    xray
    mieru
  ];

  home.sessionVariables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
  };

  programs = {
    mise = {
      enable = true;
      # package = null;
      enableZshIntegration = false;
      globalConfig = {
        tools = {
          # node = "latest";
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
      enableZshIntegration = false; # Managed by zim
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
      package = null;
      enableGitIntegration = false;
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
      enable = true;
      package = null;
      settings = {
        autoupdate = false;
        share = "disabled";
        snapshot = false;
        lsp = false;
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
      enable = true;
      package = null;
      clientSettings = {
        autoOpenPlanSidebar = true;
        sidebarV2Enabled = true;
        wordWrap = true;
        diffIgnoreWhitespace = true;
        favorites = [
          {
            provider = "codex";
            model = "gpt-5.6-sol";
          }
          {
            provider = "codex";
            model = "gpt-5.6-terra";
          }
          {
            provider = "codex";
            model = "gpt-5.6-luna";
          }
          {
            provider = "codex";
            model = "gpt-5.3-codex-spark";
          }
        ];
      };
      userSettings = {
        enableAssistantStreaming = true;
        enableProviderUpdateChecks = false;
        addProjectBaseDirectory = "~/Documents/";
      };
      keybindings = [ ];
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
      enable = false;
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
