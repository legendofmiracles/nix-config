{
  description = "A minimal NixOS configuration using Nix Flakes.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs.url = "github:nix-community/emacs-overlay";
    nur.url = "github:nix-community/NUR";
    hardware.url = "github:NixOS/nixos-hardware/master";
  };
  outputs = inputs@{ self, nixpkgs, home, emacs, nur, hardware }: {
    nixosConfigurations.superfluous = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nix = {
            extraOptions = "experimental-features = nix-command flakes";
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
            autoOptimiseStore = true;
            binaryCachePublicKeys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
            binaryCaches = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
            ];
          };
          nixpkgs = let
            lib = nixpkgs.lib;
            folder = ./overlays;
            toPath = name: value: folder + ("/" + name);
            filterCaches = key: value: value == "regular" && nixpkgs.lib.hasSuffix ".nix" key;
            userOverlays = lib.lists.forEach (lib.mapAttrsToList toPath (lib.filterAttrs filterCaches (builtins.readDir folder))) import;
          in {
            config = {
              allowUnfree = true;
              allowBroken = true;
            };
            overlays = [
              emacs.overlay
              nur.overlay
            ] ++ userOverlays;
          };
        }
        ./nixos/configuration.nix
        home.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.fortuneteller2k = import ./home/fortuneteller2k.nix;
          };
        }
      ];
      specialArgs = { inherit inputs; };
    };
    superfluous =
      self.nixosConfigurations.superfluous.config.system.build.toplevel;
  };
}
