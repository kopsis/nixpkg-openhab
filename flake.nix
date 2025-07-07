{
  description = "Simple packaging of OpenHAB home automation service";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { 
    self,
    flake-utils, 
    nixpkgs, 
    ... 
  }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in
      {
        overlays."openhab" = final: prev: {
          jdk-openhab = final.callPackage ./jdk.nix {};
          openhab = final.callPackage ./openhab.nix {};
          openhab-addons = final.callPackage ./openhab-addons.nix {};
        };

        overlays.default = self.overlays.openhab;
        
        packages = forAllSystems (system:
          {
            inherit (nixpkgsFor.${system}) openhab;
          });

        defaultPackage = forAllSystems (system: self.packages.${system}.openhab);
      };


  #    let
  #      out = system:
  #        let
  #          pkgs = nixpkgs.legacyPackages.${system};
  #          appliedOverlay = self.overlays.default pkgs pkgs;
  #        in
  #        {
  #          packages.openhab = appliedOverlay.openhab;
  #        };
  #
  #    in
  #      flake-utils.lib.eachDefaultSystem out // {
  #        overlays.default = final: prev: {
  #          jdk-openhab = final.callPackage ./jdk.nix {};
  #          openhab = final.callPackage ./openhab.nix {};
  #          openhab-addons = final.callPackage ./openhab-addons.nix {};
  #        };
  #    };
}
