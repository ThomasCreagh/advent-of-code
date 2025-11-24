{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        zig
      ];
      env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      ];

      shellHook = ''
        echo "welcome to the shell"
      '';
    };
  };
}

