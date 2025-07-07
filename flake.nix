{
    description = "Simple packaging of OpenHAB home automation service";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { 
        flake-utils, 
        nixpkgs, 
        ... 
    }: let
        overlay = final: prev: rec {
            jdk-openhab = final.callPackage ./jdk.nix {};
            openhab = final.callPackage ./openhab.nix { };
            openhab-addons = final.callPackage ./openhab-addons.nix {};
        };

        eachSystem = nixpkgs.lib.genAttrs ( [ "x86_64-linux" "aarch64-linux" ] );
    in {
        overlays.default = overlay;

        formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);

        packages = eachSystem (system: {
            jdk-openhab = (pkgs system).jdk-openhab;
            openhab = (pkgs system).openhab;
            openhab-addons = (pkgs system).openhab-addons;
        });
    };
}
