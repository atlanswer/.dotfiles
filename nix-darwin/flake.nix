{
  description = "Nix-darwin system flake for Bad Apple";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
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
            SSH_SK_PROVIDER = "/usr/lib/ssh-keychain.dylib";
          };

          homebrew = {
            enable = true;
            enableZshIntegration = true;
            brews = [ ];
            greedyCasks = true;
            casks = [
              "zed"
              "tailscale-app"
              "helium-browser"
              "affinity"
              "android-studio"
              "t3-code"
              "codex"
              "codex-app"
              "windows-app"
            ];
            masApps = {
              "Apple Developer" = 640199958;
            };
            global = {
              autoUpdate = true;
              brewfile = true;
            };
            onActivation = {
              autoUpdate = true;
              upgrade = true;
              cleanup = "zap";
              extraEnv = proxy_list;
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

          networking.hostName = "bad-apple";
          networking.computerName = "Bad Apple";
          time.timeZone = "Asia/Shanghai";
          fonts.packages = with pkgs; [
            nerd-fonts.fira-code
          ];
          nixpkgs.hostPlatform = hostPlatform;
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "rar" ];
          # nixpkgs.overlays = [ ( final: prev: {
          #   inherit (prev.lixPackageSets.stable)
          #     nixpkgs-review
          #     nix-eval-jobs
          #     nix-fast-build
          #     colmena;
          # }) ];
          # Nix settings
          # nix.package = pkgs.lixPackageSets.stable.lix;
          launchd.daemons.nix-daemon.serviceConfig.EnvironmentVariables = proxy_list;
          nix.package = pkgs.lix;
          nix.settings.experimental-features = "nix-command flakes";
          nix.channel.enable = false;
          nix.optimise.automatic = true;
          nix.gc.automatic = true;
          security.pam.services = {
            sudo_local = {
              reattach = true;
              touchIdAuth = true;
            };
          };
          users.users.atlanswer.shell = pkgs.zsh;
          system.primaryUser = "atlanswer";
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
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users = {
                atlanswer = ./home.nix;
              };
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
}
