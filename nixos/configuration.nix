# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Partition mapping
  fileSystems."/" = {
    device = "/dev/nvme1n1p2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/nvme1n1p1";
    fsType = "vfat";
  };

  networking.hostName = "homelab-0";
  time.timeZone = "Europe/Poland";

  networking.networkmanager.enable = true;
  
  # without this group docker won't run as a service
  users.groups.docker = {};

  # user configuration
  users.users.jakub = {
    isNormalUser = true;
    extraGroups = [ 
    "wheel" 
    "docker"
    ];
    packages = with pkgs; [
      tree
    ];
    hashedPassword = "$6$j7Fz9JrQWame.tEf$nQZGQmeOqawIR.gqCczoWgDIXT/R3mC1j5LwiBCFkGIelnjbbeamEBx8lkl8XyLxCMLad7JR/quZ8lrpjYOlY.";
  
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4Hnf6bCp3vi7S3/dzoo8O3EpbqnSuu3bE/IMbQ9Yobrfooq+QNZj8iExxKoi9PHK18uTKYoOyuumoCsMUir/IgegCNMozXxUmD2Jvu6vvO5Jf5tum15f0l0ZQrZNCsejdXJ9Tk7h53qkcjzCYRKtoQsr5+j9o56/t5m8Ixmz/nZbrUy69+lsNWpqkPHkhX00QHSuLvRPRP+zHI/XT1hvqs4pT0MFJ6LPYD2pw42RrAoP1Df9xmviuutcPocilrfT45jLsAkVTLtpuW5LmusWcoGaxoEmraf4lYIVyrDdxHG5FXaSs1kyBSBob8e09H7h21jvMIWbVqqKHHOza3LPHZ/h2RBstkuAfR6rT2RG0bB7aGk0gKnVZhLquaXn9eHozJcK8ZxOuIOrvrKNcEVy0Eqp7nDHQ0nQkJbxUsvuvrKskfBd25VVcSIRGqWKrUwl/8gzkQ456C5vzfKGQOSsgZxZ5ZxUBLvlDhxmTlqYPZBIP2gbK/vXkSikGZ8eOHYU= jakub@jakub-System-Product-Name"
    ];
  };

  # system packages
  environment.systemPackages = with pkgs; [
    k3s
    neovim
    wget
    git
    neofetch
    docker
    cifs-utils
    nfs-utils
    kubernetes-helm
    helmfile
  ];

  virtualisation.docker.enable = true;

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString ([
      "--write-kubeconfig-mode \"0644\""
      "--cluster-init"
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
    ]);
    clusterInit = true;
  };

  services.openssh.enable = true;
  networking.firewall.enable = false;

  # Do not change
  system.stateVersion = "24.11";

}