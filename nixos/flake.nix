{
  description = "Homelab NixOS Flake";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    # Sops and secrets
    agenix.url = "github:ryantm/agenix";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, flake-utils, disko, agenix, sops-nix }@inputs: let
    nodes = [
      "homelab-0"
    ];
  in {
    packages = {
        helm = pkgs.helm;
        helmfile = pkgs.helmfile;
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

    devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
            helm
            helmfile
            age
            sops
        ];
    };
  };
}
