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
    # paneru = {
    #   url = "github:karinushka/paneru";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
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
          imports = [
            # inputs.paneru.darwinModules.paneru
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
              ### Dev
              "node" # homebrew version doesn't support Temporal: https://github.com/Homebrew/homebrew-core/pull/281707
              "pnpm"
              "bun"
              "go"
              "odin"
              "rust"
              "cargo-cache"
              "cargo-update"
              ### Toolchain
              "ninja"
              "ccache"
              "cmake"
              # "mise"
              # "vite-plus"
              "tree-sitter-cli"
              "lua-language-server"
              "bear"
              ### AI
              "llama.cpp"
              "opencode"
              ### Mobile
              "watchman"
              "fastlane"
              ### iOS
              "cocoapods"
              ### Cli
              "mpv"
              "iproute2mac"
              ### Proxy
              {
                name = "mihomo";
                postinstall = "ln -sfn /Users/atlanswer/.config/mihomo/config.yaml /opt/homebrew/etc/mihomo/config.yaml";
                restart_service = "changed";
              }
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
              "t3-code"
              "codex"
              "chatgpt"
              "tidal"
              ### Toolchains
              "gcc-arm-embedded"
              ### Tools
              "skim"
              "moonlight"
              "localsend"
              "windows-app"
              "linearmouse"
              "imaging-edge"
              # "jlcone"
              ### Hardware
              "segger-jlink"
              ### Modeling
              "autodesk-fusion"
              "kicad"
              "freecad"
              "bambu-studio"
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

          # services.paneru.enable = false;

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
          nixpkgs.config = {
            android_sdk.accept_license = true;
            allowUnfreePredicate =
              pkg:
              pkgs.lib.getName pkg == "rar"
              || (pkg.meta.homepage or null) == "https://developer.android.com/tools";
          };
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
          system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;
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
