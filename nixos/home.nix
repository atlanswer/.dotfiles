{ lib, config, pkgs, ...}:
# let
#   androidenv = pkgs.androidenv.override {
#     licenseAccepted = true;
#   };
#   buildToolsVersion = "36.1.0";
#   androidComposition = androidenv.composeAndroidPackages {
#     cmdLineToolsVersion = "latest";
#     platformToolsVersion = "latest";
#     platformVersions = [ "36" ];
#     buildToolsVersions = [ buildToolsVersion ];
#     abiVersions = [ "arm64-v8a" ];
#     includeNDK = "if-supported";
#     includeCmake = "if-supported";
#     includeEmulator = false;
#     toolsVersion = null;
#   };
# in
{
  home = {
    username = "atlanswer";
    homeDirectory = "/home/atlanswer";

    stateVersion = "26.05";

    packages = with pkgs; [
      # Programming languages
      ## C/C++
      clang clang-tools libclang.lib
      # JavaScript
      nodejs_latest
      # Rust
      rustc cargo cargo-cache cargo-update
      # Android SDK
      # androidComposition.androidsdk
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

    sessionVariables = rec {
      LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
      # ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
      # ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
      # GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
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
    # initExtra = ''
    #   export PATH = "$(echo "$ANDROID_HOME/cmake/${cmakeVersion}".*/bin):$PATH"
    # '';
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
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "atlanswer";
      user.email = "i@atlanswer.com";
      core.autocrlf = "input";
      init.defaultBranch = "main";
      color.ui = true;
      pull.rebase = false;
      pull.ff = "only";
      fetch.rebase = false;
      fetch.ff = "only";
      fetch.prune = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
      gpg.ssh.defaultKeyCommand = "ssh-add -L";
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

  programs.java = {
    enable = true;
    package = pkgs.jetbrains.jdk-no-jcef;
  };
}
