{
  description = "Nix-darwin system flake for Bad Apple";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      android-nixpkgs,
      ...
    }:
    let
      username = "atlanswer";
      nix-darwin-config =
        { pkgs, ... }:
        let
          hostPlatform = "aarch64-darwin";
          proxy_list =
            let
              socks_proxy = "socks5h://localhost:1080";
              http_proxy = "http://localhost:1080";
              noProxy = "127.0.0.1,::1,localhost";
            in
            {
              http_proxy = http_proxy;
              https_proxy = http_proxy;
              all_proxy = socks_proxy;
              no_proxy = noProxy;

              HTTP_PROXY = http_proxy;
              HTTPS_PROXY = http_proxy;
              ALL_PROXY = socks_proxy;
              NO_PROXY = noProxy;
            };
        in
        {
          nixpkgs.overlays = [ android-nixpkgs.overlays.default ];
          imports = [
            inputs.paneru.darwinModules.paneru
          ];
          # List packages installed in system profile
          # To search by name, run: $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            neovim
            git
            curl
            wget
          ];
          environment.variables = {
            EDITOR = "nvim";
            # Touch ID for SSH agent: https://gist.github.com/arianvp/5f59f1783e3eaf1a2d4cd8e952bb4acf
            # SSH_SK_PROVIDER = "/usr/lib/ssh-keychain.dylib";
          };

          homebrew = {
            enable = true;
            enableZshIntegration = true;
            brews = [
              # Dev
              "mise"
              # "node" # homebrew version doesn't support Temporal: https://github.com/Homebrew/homebrew-core/pull/281707
              "pnpm"
              "vite-plus"
              "rust"
              "go"
              # "rustup"
              "skopeo"
              "tree-sitter-cli"
              "lua-language-server"
              "stylua"
              "llama.cpp"
              # "hf"
              "opencode"
              "pi-coding-agent"
              # Mobile
              "watchman"
              "fastlane"
              # iOS
              "cocoapods"
              "ccache"
              # Cli
              "scc"
              "dua-cli"
              "dust"
              "xh"
              "wget"
              "iproute2mac"
              "tree"
              "stow"
              # Utils
              "mas"
              "sevenzip"
              # Others
              "mpv"
              "typst"
              # Proxy
              {
                name = "mihomo";
                postinstall = "ln -sfn /Users/atlanswer/.config/mihomo/config.yaml /opt/homebrew/etc/mihomo/config.yaml";
                restart_service = "changed";
              }
              "hysteria"
            ];
            greedyCasks = true;
            casks = [
              "zed"
              "tailscale-app"
              "zen"
              "helium-browser"
              "affinity"
              "orbstack"
              # "android-studio"
              "sf-symbols"
              "opencode-desktop"
              "t3-code@nightly"
              "codex"
              "chatgpt"
              # Tools
              "moonlight"
              "localsend"
              "windows-app"
              # Hardware
              "segger-jlink"
              # Modeling
              "freecad"
              "kicad"
            ];
            masApps = {
              "Xcode" = 497799835;
              "Apple Developer" = 640199958;
              "GarageBand" = 682658836;
              "Pages: Create Documents" = 361309726;
              "Numbers: Make Spreadsheets" = 361304891;
              "Keynote: Design Presentations" = 361285480;
            };
            global = {
              autoUpdate = true;
              brewfile = true;
            };
            onActivation = {
              autoUpdate = true;
              upgrade = true;
              cleanup = "zap";
              extraEnv = proxy_list // {
                HOMEBREW_CLEANUP_MAX_AGE_DAYS = "7";
                HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS = "7";
              };
            };
          };

          programs.tmux = {
            enable = true;
            enableFzf = true;
            enableMouse = true;
            enableSensible = true;
            enableVim = true;
          };

          programs.zsh.enable = true;

          users.users.${username} = {
            shell = pkgs.zsh;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBj7491dQsMgG2O7QJHdA3DVTZm0u5X4O0zlKT9fI5A8 Striker"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnTuBiMnpmBK3Uvy/fALA84aJygEcEgUfVKUzPGD9tC Contestant"
            ];
          };

          services.openssh = {
            enable = true;
            extraConfig = ''
              # Key-only login
              PasswordAuthentication no
              KbdInteractiveAuthentication no
              ChallengeResponseAuthentication no
              PubkeyAuthentication yes

              # Avoid accidentally allowing root/admin escalation over SSH
              PermitRootLogin no

              # Keep forwarding off by default; enable per-host later if needed
              AllowAgentForwarding no
              AllowTcpForwarding no
              X11Forwarding no

              # Only allow SSH source addresses from the Tailscale CGNAT range.
              # This avoids binding sshd to a dynamic Tailscale interface/IP.
              AllowUsers ${username}@100.64.0.0/10
            '';
          };

          services.paneru = {
            enable = true;
            settings = {
              options = {
                focus_follows_mouse = true;
                mouse_follows_focus = false;
                animation_speed = 50;
                virtual_workspace_animations = true;
                preset_column_widths = [
                  0.5
                  0.666
                ];
                insert_windows_mid_strip = true;
              };
              swipe = {
                sensitivity = 0.40;
                deceleration = 5.0;
                continuous = false;
                gesture = {
                  fingers_count = 3;
                };
              };
              bindings = {
                window_focus_west = "rcmd - h";
                window_swap_west = "rcmd + shift - h";
                window_focus_east = "rcmd - l";
                window_swap_east = "rcmd + shift - l";
                window_stack = "rcmd + alt - h";
                window_unstack = "rcmd + alt - l";
                window_manage = "rcmd - v";
                window_center = "rcmd - c";
                window_resize = "rcmd - r";
                window_fullwidth = "rcmd - f";
                window_raise_floating = "rcmd + shift - f";

                window_virtual_north = "rcmd - k";
                window_virtual_south = "rcmd - j";
                window_virtualmove_north = "rcmd + shift - k";
                window_virtualmove_south = "rcmd + shift - j";
                window_virtualnum_1 = "rcmd - 1";
                window_virtualnum_2 = "rcmd - 2";
                window_virtualnum_3 = "rcmd - 3";
                window_virtualmovenum_1 = "rcmd + alt - 1";
                window_virtualmovenum_2 = "rcmd + alt - 2";
                window_virtualmovenum_3 = "rcmd + alt - 3";
                window_virtualsendnum_1 = "rcmd + shift - 1";
                window_virtualsendnum_2 = "rcmd + shift - 2";
                window_virtualsendnum_3 = "rcmd + shift - 3";

                quit = "rcmd + shift - m";
                restart = "rcmd + alt - m";
              };
            };
          };

          networking.hostName = "bad-apple";
          networking.computerName = "Bad Apple";
          time.timeZone = "Asia/Shanghai";
          fonts.packages = with pkgs; [
            nerd-fonts.fira-code
            geist-font
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
          ];
          nixpkgs.hostPlatform = hostPlatform;
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "rar" ];
          # Nix settings
          launchd.daemons.nix-daemon.serviceConfig.EnvironmentVariables = proxy_list;
          # nixpkgs.overlays = [ ( final: prev: {
          #   inherit (prev.lixPackageSets.stable)
          #     nixpkgs-review
          #     nix-eval-jobs
          #     nix-fast-build
          #     colmena;
          # }) ];
          # nix.package = pkgs.lix;
          nix.package = pkgs.lixPackageSets.stable.lix;
          nix.settings.experimental-features = "nix-command flakes";
          nix.channel.enable = false;
          nix.optimise.automatic = true;
          nix.gc = {
            automatic = true;
            interval = [
              {
                Weekday = 1;
                Hour = 9;
                Minute = 15;
              }
            ];
            options = "--delete-older-than 7d";
          };
          security.pam.services = {
            sudo_local = {
              reattach = true;
              touchIdAuth = true;
            };
          };
          system.primaryUser = username;
          system.keyboard = {
            enableKeyMapping = true;
            remapCapsLockToEscape = true;
          };
          # Set Git commit hash for darwin-version
          system.configurationRevision = self.rev or self.dirtyRev or null;
          # Used for backwards compatibility, please read the changelog before changing
          # $ darwin-rebuild changelog
          system.stateVersion = 6;
        };
    in
    {
      darwinConfigurations.bad-apple = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          nix-darwin-config
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users = {
                ${username} = ./home.nix;
              };
            };
          }
        ];
      };
    };
}
