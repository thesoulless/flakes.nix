{
  description = "";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    nixpkgs-python.inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      devenv,
      systems,
      ...
    }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      pkgs-unstable = import nixpkgs-unstable { inherit nixpkgs; };
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              {
                # https://devenv.sh/reference/options/
                packages = [
                  # pkgs.ruff
                ];

                # https://devenv.sh/basics/
                env = { GREET = "Your dev env is all set 🍻"; };

                # https://devenv.sh/scripts/
                scripts.hello.exec = "echo $GREET";

                enterShell = ''
                  hello
                '';

                # https://devenv.sh/pre-commit-hooks/
                pre-commit.hooks = {};

                languages.python = {
                  enable = true;
                  version = "3.12";
                  venv.enable = true;
                  #   uv = {
                  #     enable = true;
                  #     package = pkgs-unstable.uv;
                  #     sync.enable = true;
                  #   };
                };
              }
            ];
          };
        }
      );
    };
}
