# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, meta, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = meta.hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Poland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Fixes for longhorn
#  systemd.tmpfiles.rules = [
#    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
#  ];

  virtualisation.docker.logDriver = "json-file";

  services.k3s = {
    enable = true;
    role = "server";
#    tokenFile = ;
    extraFlags = toString ([
	    "--write-kubeconfig-mode \"0644\""
	    "--cluster-init"
	    "--disable servicelb"
	    "--disable traefik"
	    "--disable local-storage"
    ] ++ (if meta.hostname == "homelab-0" then [] else [
	      "--server https://homelab-0:6443"
    ]));
    clusterInit = (meta.hostname == "homelab-0");
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jakub = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    # Created using mkpasswd
    hashedPassword = "$6$koSJxMEhJA5e/3U.$kzeUicYPRGo2pSmzMeQseVmJfV99cnrO60c7wvWJyj6zIMPUff3ipTGw5EtPVCMgsqVcadR.dWWhWyl7JZv.Q/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4Hnf6bCp3vi7S3/dzoo8O3EpbqnSuu3bE/IMbQ9Yobrfooq+QNZj8iExxKoi9PHK18uTKYoOyuumoCsMUir/IgegCNMozXxUmD2Jvu6vvO5Jf5tum15f0l0ZQrZNCsejdXJ9Tk7h53qkcjzCYRKtoQsr5+j9o56/t5m8Ixmz/nZbrUy69+lsNWpqkPHkhX00QHSuLvRPRP+zHI/XT1hvqs4pT0MFJ6LPYD2pw42RrAoP1Df9xmviuutcPocilrfT45jLsAkVTLtpuW5LmusWcoGaxoEmraf4lYIVyrDdxHG5FXaSs1kyBSBob8e09H7h21jvMIWbVqqKHHOza3LPHZ/h2RBstkuAfR6rT2RG0bB7aGk0gKnVZhLquaXn9eHozJcK8ZxOuIOrvrKNcEVy0Eqp7nDHQ0nQkJbxUsvuvrKskfBd25VVcSIRGqWKrUwl/8gzkQ456C5vzfKGQOSsgZxZ5ZxUBLvlDhxmTlqYPZBIP2gbK/vXkSikGZ8eOHYU= jakub@jakub-System-Product-Name"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     neovim
     k3s
     cifs-utils
     nfs-utils
     git
     neofetch
     docker
     (wrapHelm kubernetes-helm) {
        plugins = with pkgs.kubernetes-helmPlugins; [
            helm-secrets
            helm-diff
            helm-s3
            helm-git
        ];
     }
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "23.11";
}
