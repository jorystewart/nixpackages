{
  description = "Local package repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" ];
      forAllSystems = lib.genAttrs systems;

      names = builtins.attrNames
        (lib.filterAttrs (n: type: type == "directory" && builtins.pathExists ././${n}/${n}.nix) (builtins.readDir ./.));
    in
    {
      overlays.default = final: _prev: {
        local = lib.makeScope final.newScope (self:
          lib.genAttrs names (n: self.callPackage ././${n}/${n}.nix { }));
      };

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        lib.genAttrs names (n: pkgs.local.${n}));
      
      nixosModules.default = { pkgs, ... }: {
        nixpkgs.overlays = [ self.overlays.default ];
        _module.args.localpkgs = pkgs.local;
      };
    };
}