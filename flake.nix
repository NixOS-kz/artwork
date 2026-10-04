{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        logo = pkgs.callPackage ./logo { };
        default = logo;
      });

      apps = forAllSystems (pkgs: {
        update = {
          type = "app";
          program = pkgs.lib.getExe (pkgs.writeShellApplication {
            name = "update";
            text = "install -m 644 ${self.packages.${pkgs.stdenv.hostPlatform.system}.logo}/* logo/";
          });
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}
