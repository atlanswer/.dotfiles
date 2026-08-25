{ lib, pkgs, ... }:
let
  zshOpts = lib.mkOrder 500 ''
    ZSH_AUTOSUGGEST_MANUAL_REBIND=1
    typeset -g fzf_default_completion=complete-word
  '';
  zimInit = lib.mkOrder 550 ''
    ZDOTDIR=~/.config
    ZIM_HOME=''${ZDOTDIR:-''${HOME}}/.zim
    # Install missing modules and update ''${ZIM_HOME}/init.zsh if missing or outdated.
    if [[ ! ''${ZIM_HOME}/init.zsh -nt ''${ZIM_CONFIG_FILE:-''${ZDOTDIR:-''${HOME}}/.zimrc} ]]; then
    source ${pkgs.zimfw}/zimfw.zsh init
    fi
    # Initialize modules.
    source ''${ZIM_HOME}/init.zsh
  '';
  homebrew = lib.mkOrder 600 ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      # Use homebrew installed packages
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';
  homebrewAppend = lib.mkOrder 650 ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      export HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
      export HOMEBREW_REPOSITORY="/opt/homebrew"
      # Keep Homebrew completions available, but low priority
      fpath+=("/opt/homebrew/share/zsh/site-functions")
      export FPATH
      # Homebrew binaries are available
      path+=(
        /opt/homebrew/bin
        /opt/homebrew/sbin
      )
      # Optional documentation paths, also low priority
      export MANPATH="''${MANPATH:-}:/opt/homebrew/share/man"
      export INFOPATH="''${INFOPATH:-}:/opt/homebrew/share/info"
    fi
  '';
  customizations = lib.mkOrder 1500 ''
    # cargo
    export PATH="$PATH:$HOME/.cargo/bin"
    # zvm
    export PATH="$PATH:$HOME/.local/share/zvm/bin"
    # pnpm
    export PATH="$PATH:$HOME/Library/pnpm/bin"
    # bun
    # export PATH="$PATH:$HOME/.bun/bin"
    # uv
    export PATH="$PATH:$HOME/.local/bin"
    # orbstack
    path+=($HOME/.orbstack/bin)

    function setproxy() {
      export GIT_SSH_COMMAND='ssh -o ProxyCommand="nc -x 127.0.0.1:1080 -X 5 %h %p"'
      export all_proxy="socks5h://localhost:1080"
      export ALL_PROXY=$all_proxy
      export https_proxy="http://localhost:1080"
      export HTTPS_PROXY=$https_proxy
      export http_proxy=$https_proxy
      export HTTP_PROXY=$https_proxy
      export no_proxy="localhost,127.0.0.1,::1"
      export NO_PROXY=$no_proxy
    }

    function unsetproxy() {
      unset GIT_SSH_COMMAND
      unset all_proxy
      unset ALL_PROXY
      unset https_proxy
      unset HTTPS_PROXY
      unset http_proxy
      unset HTTP_PROXY
      unset no_proxy
      unset NO_PROXY
    }

    # Use proxy by default
    setproxy

    # Aliases
    alias opencode=opencode2
  '';
in
lib.mkMerge [
  zshOpts
  zimInit
  # homebrew
  homebrewAppend
  customizations
]
