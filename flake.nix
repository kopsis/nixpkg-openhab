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
            jdk-openhab = prev.callPackage ./jdk.nix {};
            openhab = prev.callPackage ./openhab.nix { };
            openhab-addons = prev.callPackage ./openhab-addons.nix {};
        };

        eachSystem = nixpkgs.lib.genAttrs ( [ "x86_64-linux" "aarch64-linux" ] );
    in {
        overlays.default = overlay;

        formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);

        packages = eachSystem (system: {
            jdk-openhab = nixpkgs.legacyPackages.${system}.callPackage ./jdk.nix {};
            openhab = nixpkgs.legacyPackages.${system}.callPackage ./openhab.nix {};
            openhab-addons = nixpkgs.legacyPackages.${system}.callPackage ./openhab-addons.nix {};
        });
    };
}
