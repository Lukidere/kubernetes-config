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
        "z83" = nixpkgs.lib.nixosSystem {
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
        "hp1" = nixpkgs.lib.nixosSystem {

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
        "hp2" = nixpkgs.lib.nixosSystem {

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
