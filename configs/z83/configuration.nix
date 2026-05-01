# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  age.secrets."k3s-token".file = ../secrets/k3s-token.age;
  age.secrets."password".file = ./haslo-root.age;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "z83"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEX1Ja0Tkcp/bW75Y12iwZKMAo/6VFwkvUJQ24qN4kF koniecznyrad@gmail.com"

    ];
  };
  #user
  users.users.user = {
    isNormalUser = true;
    hashedPassword = config.secrets.age."password".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEX1Ja0Tkcp/bW75Y12iwZKMAo/6VFwkvUJQ24qN4kF koniecznyrad@gmail.com"

    ];
    extraGroups = [
      "
      wheel
      "
    ];
  };
  services.openssh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
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
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = false;
  #networking.firewall.allowedUDPPorts = [ ... ];
  services.k3s = {
    enable = true;
    role = "server";
    token = config.age.secrets."k3s-token".path;
    clusterInit = true;
    extraFlags = "--write-kubeconfig-mode 644 --bind-address 0.0.0.0 192.168.88.5";
  };

  system.stateVersion = "25.11"; # Did you read the comment?

}
