{ lib, ...}: let
  zshOpts = lib.mkOrder 500 ''
    bindkey -v
  '';
  zimInit = lib.mkOrder 550 ''
    ZIM_CONFIG_FILE=~/.config/zimrc
    ZIM_HOME=''${ZDOTDIR:-''${HOME}}/.zim
    # Download zimfw plugin manager if missing.
    if [[ ! -e ''${ZIM_HOME}/zimfw.zsh ]]; then
    mkdir -p ''${ZIM_HOME} && wget -nv -O ''${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    fi
    # Install missing modules and update ''${ZIM_HOME}/init.zsh if missing or outdated.
    if [[ ! ''${ZIM_HOME}/init.zsh -nt ''${ZIM_CONFIG_FILE:-''${ZDOTDIR:-''${HOME}}/.zimrc} ]]; then
      source ''${ZIM_HOME}/zimfw.zsh init
    fi
    # Initialize modules.
    source ''${ZIM_HOME}/init.zsh
  '';
  customizations = lib.mkOrder 1500 ''
    # cargo
    export PATH="$PATH:$HOME/.cargo/bin"
    # zvm
    export PATH="$PATH:$HOME/.local/share/zvm/bin"
    # uv
    export PATH="$PATH:$HOME/.local/bin"
    # bun
    export PATH="$PATH:$HOME/.bun/bin"

    function setproxy() {
      export all_proxy="socks5://localhost:1080"
      export ALL_PROXY=$all_proxy
      export https_proxy="http://localhost:1080"
      export HTTPS_PROXY=$https_proxy
      export http_proxy=$https_proxy
      export HTTP_PROXY=$https_proxy
      export no_proxy="localhost,127.0.0.1,::1"
      export NO_PROXY=$no_proxy
    }

    function unsetproxy() {
      unset all_proxy
      unset ALL_PROXY
      unset https_proxy
      unset HTTPS_PROXY
      unset http_proxy
      unset HTTP_PROXY
      unset no_proxy
      unset NO_PROXY
    }
  '';
in
  lib.mkMerge [ zimInit zshOpts customizations ]
