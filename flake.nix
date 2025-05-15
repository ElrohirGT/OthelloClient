{
  description = "Othello client flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # System types to support.
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
    pythonPkgs = p: with p; [random2 requests];
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      python = pkgs.python3.withPackages pythonPkgs;
    in {
      default = pkgs.writeShellApplication {
        name = "othello_client";
        runtimeInputs = [python];
        text = ''
          python ./othello_client/othello_player.py "$1" "$2"
        '';
      };
    });
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      # python = pkgs.python3.withPackages (p: [p.requests p.random2 p.sys p.time]);
      python = pkgs.python3.withPackages pythonPkgs;
    in {
      default = pkgs.mkShell {
        packages = [python pkgs.black];
      };
    });
  };
}
