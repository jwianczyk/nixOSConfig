{
  description = "Homelab NixOS Flake";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    # Sops and secrets
    agenix.url = "github:ryantm/agenix";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, flake-utils, disko, agenix, sops-nix }@inputs: let
    nodes = [
      "homelab-0"
    ];
  in {
    packages = {
        helm = nixpkgs.helm;
        helmfile = nixpkgs.helmfile;
    };
    nixosConfigurations = builtins.listToAttrs (map (name: {
	    name = name;
	    value = nixpkgs.lib.nixosSystem {
     	    specialArgs = {
            meta = { hostname = name; };
          };
          system = "x86_64-linux";
          modules = [
              # Modules
	            disko.nixosModules.default
	            agenix.nixosModules.default
	            sops-nix.nixosModules.default
	            ./hardware-configuration.nix
	            ./disko-config.nix
	            ./configuration.nix
	          ];
        };
    }) nodes);

    devShells.default = nixpkgs.mkShell {
        buildInputs = with nixpkgs; [
            helm
            helmfile
            age
            sops
        ];
    };
  };
}
