{
  description = "Kubernetes claster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , agenix
    , ...
    }@inputs:
    {
      nixosConfigurations = {
        "z83-server" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            agenix.nixosModules.default
            "./configs/z83/configuration.nix"
            "./configs/z83/hardware-configuration.nix"
          ];
        };
        "HP1-worker" = nixpkgs.lib.nixosSystem {

          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            agenix.nixosModules.default
            "./configs/hp1/configuration.nix"
            "./configs/hp1/hardware-configuration.nix"
          ];
        };
        "HP2-worker" = nixpkgs.lib.nixosSystem {

          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            agenix.nixosModules.default
            "./configs/hp2/configuration.nix"
            "./configs/hp2/hardware-configuration.nix"
          ];
        };
      };
    };
}
