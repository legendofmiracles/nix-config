{
  description = "A somewhat huge NixOS configuration using Nix Flakes.";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    emacs.url = "github:nix-community/emacs-overlay";
    home.url = "github:nix-community/home-manager";
    manix.url = "github:mlvzk/manix";
    neovim.url = "github:neovim/neovim?dir=contrib";
    nur.url = "github:nix-community/NUR";
    review.url = "github:Mic92/nixpkgs-review";
    rust.url = "github:oxalica/rust-overlay";

    # Nixpkgs branches
    master.url = "github:nixos/nixpkgs/master";
    stable.url = "github:nixos/nixpkgs/release-21.05";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    polybar.url = "github:fortuneteller2k/nixpkgs/polybar";

    /*
      NOTE: don't use this, if you're not me or a maintainer of the XanMod kernel in Nixpkgs

      I nuke this branch from time to time.
    */
    # kernel.url = "github:fortuneteller2k/nixpkgs/update-xanmod-512";

    # Default Nixpkgs for packages and modules
    nixpkgs.follows = "master";
  };

  outputs = { self, agenix, home, nixpkgs, ... } @ inputs:
    with nixpkgs.lib;
    let
      config = {
        allowBroken = true;
        allowUnfree = true;
        /*
          NOTE: experimental option, disable if you don't know what this does

          See https://github.com/NixOS/rfcs/pull/62 for more information.
        */
        contentAddressedByDefault = false;
      };

      filterNixFiles = k: v: v == "regular" && hasSuffix ".nix" k;

      importNixFiles = path: (lists.forEach (mapAttrsToList (name: _: path + ("/" + name))
        (filterAttrs filterNixFiles (builtins.readDir path)))) import;

      overlays = with inputs; [
        (final: _:
          let
            system = final.stdenv.hostPlatform.system;
          in
          {
            # Packages provided by flake inputs
            agenix = agenix.defaultPackage.${system};
            manix = manix.defaultPackage.${system};
            neovim-nightly = neovim.packages.${system}.neovim;
            nixpkgs-review = review.defaultPackage.${system};

            /*
              Nixpkgs branches

              One can access these branches like so:

              `pkgs.stable.mpd'
              `pkgs.master.linuxPackages_xanmod'
            */
            master = import master { inherit config system; };
            unstable = import unstable { inherit config system; };
            stable = import stable { inherit config system; };
            poly = import polybar { inherit config system; };

            # NOTE: Remove this, if you're not me or a maintainer of the XanMod kernel in Nixpkgs
            kernel = import inputs.kernel { inherit config system; };
          })

        # Overlays provided by inputs
        emacs.overlay
        nur.overlay
        rust.overlay
      ]
      # Overlays from ./overlays directory
      ++ (importNixFiles ./overlays);
    in
    {
      nixosConfigurations.superfluous = import ./hosts/superfluous {
        inherit config agenix home inputs nixpkgs overlays;
      };

      superfluous = self.nixosConfigurations.superfluous.config.system.build.toplevel;
    };
}
