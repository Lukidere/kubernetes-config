{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];
  #secrets
  age.secrets."k3s-token".file = ../secrets/k3s-token.age;
  age.secrets."password".file = ./haslo-root.age;
  #system configs
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "HP-2"; # Define your hostname.
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Amsterdam";
  users.users.root = {

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEX1Ja0Tkcp/bW75Y12iwZKMAo/6VFwkvUJQ24qN4kF koniecznyrad@gmail.com"

    ];
  };
  #user
  users.users.user = {
    isNormalUser = true;
    hashedPassword = config.age.secrets."password".path;
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

  networking.firewall.enable = false;
  services.k3s = {
    enable = true;
    role = "
      agent
      ";
    token = config.age.secrets."
      k3s-token
      ".path;
    serverAddr = "
      https://192.168.88.5:6443
      ";
  };

  system.stateVersion = "
      25.11
      ";

}
