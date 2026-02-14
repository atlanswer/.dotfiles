# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }: {
    nixosConfigurations = {
      nixos-wsl = nixpkgs.lib.nixosSystem {
        modules = [
	  ({ pkgs, ... }: {
            # Nix settings
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
	    nix.optimise.automatic = true;
	    nix.gc.automatic = true;
            # Global packages
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
            # Global environment
            # environment.systemPackages = with pkgs; [ tree-sitter ];
            # environment.variables.EDITOR = "nvim";
	    # Users
	    users.users.atlanswer.shell = pkgs.zsh;
            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It's perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
            system.stateVersion = "26.05";
	    # System settings
	    security.sudo.wheelNeedsPassword = true;
	    networking.hostName = "nixos-wsl";
            time.timeZone = "Asia/Shanghai";
	  })
	  home-manager.nixosModules.home-manager {
	    home-manager = {
	      useGlobalPkgs = true;
	      useUserPackages = true;
	      users.atlanswer = import ./home.nix;
	      backupFileExtension = "backup";
	    };
	  }
          nixos-wsl.nixosModules.default {
	    wsl = {
              enable = true;
	      defaultUser = "atlanswer";
	      ssh-agent.enable = true;
	      useWindowsDriver = true;
	    };
	  }
          ./hardware-configuration.nix
        ];
      };
    };
  };
}
