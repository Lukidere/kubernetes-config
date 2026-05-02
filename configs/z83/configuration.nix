{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # secrets
  age.secrets."k3s-token".file = ../secrets/k3s-token.age;
  age.secrets."password".file = ./haslo-root.age;
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];
  # system configs
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "z83"; # Define your hostname.
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Amsterdam";

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEX1Ja0Tkcp/bW75Y12iwZKMAo/6VFwkvUJQ24qN4kF koniecznyrad@gmail.com"
    ];
  };

  # user
  users.users.user = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."password".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEX1Ja0Tkcp/bW75Y12iwZKMAo/6VFwkvUJQ24qN4kF koniecznyrad@gmail.com"
    ];
    extraGroups = [ "wheel" ];
  };

  services.openssh = {
    enable = true;
  };
  environment.variables = { };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    fluxcd
  ];
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

  };
  networking.firewall.enable = false;

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.age.secrets."k3s-token".path;
    clusterInit = true;
    extraFlags = "--write-kubeconfig-mode 644 --bind-address 0.0.0.0 --node-ip 192.168.88.5";
  };

  system.stateVersion = "25.11";
}
