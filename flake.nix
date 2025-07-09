{
  description = "Simple packaging of OpenHAB home automation service";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { 
    self,
    flake-utils, 
    nixpkgs, 
    ... 
  }:
    let
      out = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          appliedOverlay = self.overlays.default pkgs pkgs;
        in
        {
          packages.openhab = appliedOverlay.openhab;
        };

    in
      flake-utils.lib.eachDefaultSystem out // {
        overlays.default = final: prev: {
          jdk-openhab = final.callPackage ./jdk.nix {};
          openhab = final.callPackage ./openhab.nix {};
          openhab-addons = final.callPackage ./openhab-addons.nix {};
        };
    };
}
