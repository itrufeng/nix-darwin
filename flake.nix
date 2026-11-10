{
  description = "Jian's nix-darwin system flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:

  let
    username = "jianzhang";
    configuration = { pkgs, ... }: {
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # home manager
      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
      };
    };
  in
  {
    # Build darwin or switch darwin flake using:
    # $ darwin-rebuild build --flake .#Jians-Mac-mini
    # $ darwin-rebuild switch --flake .#Jians-Mac-mini
    darwinConfigurations."Jians-Mac-mini" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration

        # system
        ./darwin/default.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.${username} = import ./home/default.nix;
        }
      ];
    };
  };
}
