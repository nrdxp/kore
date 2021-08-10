{
  description = "kore flake️";

  inputs.utils.url = "github:kreisys/flake-utils";

  outputs = { self, nixpkgs, utils }: utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-darwin" "x86_64-linux" ];

    packages = { callPackages }: rec {
      inherit (callPackages self { src = ./.; }) kore;
      defaultPackage = kore;
    };
  };
}
