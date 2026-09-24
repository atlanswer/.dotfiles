{
  description = "NixOS for agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          modules = [
            ({ pkgs, ... }: {
              # Global packages
              programs.nix-ld.enable = true;
              programs.git.enable = true;
              programs.zsh = {
                enable = true;
                enableBashCompletion = true;
                vteIntegration = true;
              };
              programs.neovim = {
                enable = true;
                defaultEditor = true;
              };
              users.users.agent = {
                uid = 501;
                extraGroups = [
                  "wheel"
                  "orbstack"
                  "audio"
                ];
                # simulate isNormalUser, but with an arbitrary UID
                isSystemUser = true;
                group = "users";
                createHome = true;
                home = "/home/agent";
                homeMode = "700";
                shell = pkgs.zsh;
              };
              users.mutableUsers = false;
              nixpkgs.config.allowUnfree = true;
              # Nix settings
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              nix.channel.enable = false;
              nix.optimise.automatic = true;
              nix.gc.automatic = true;
              # System settings
              security.sudo.wheelNeedsPassword = false;
              networking = {
                dhcpcd.enable = false;
                useDHCP = false;
                useHostResolvConf = false;
              };
              systemd.network = {
                enable = true;
                networks."50-eth0" = {
                  matchConfig = {
                    Name = "eth0";
                  };
                  networkConfig = {
                    DHCP = "ipv4";
                    IPv6AcceptRA = true;
                  };
                  linkConfig = {
                    RequiredForOnline = "routable";
                  };
                };
              };
              time.timeZone = "Asia/Shanghai";
              system.stateVersion = "26.05";
            })

            # home-manager.nixosModules.home-manager
            # {
            #   home-manager = {
            #     useGlobalPkgs = true;
            #     useUserPackages = true;
            #     users.agent = import ./home.nix;
            #   };
            # }

            ./incus.nix
            ./hardware-configuration.nix
          ];
        };
      };
    };
}
