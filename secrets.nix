let
  legion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEX1Ja0Tkcp/bW75Y12iwZKMAo/6VFwkvUJQ24qN4kF koniecznyrad@gmail.com";
  z83 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOS6EGEA1N2iJB6ZttHLjBYDe5T1JMIRIYsw96V47v5C root@nixos";
  hp1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7eraTgcHpLnyfERBYY78+BLb7PAxBoDk7pyqYm4noI root@nixos";
  hp2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEv+c0OwXL9EAeNmLdsMqM4SSod6U9K1HSjbfOEgYqOZ root@nixos";
  workers = [
    hp1
    hp2
  ];
  cluster = [
    hp1
    hp2
    z83
  ];
in
{
  "configs/z83/haslo-root.age".publicKeys = [
    legion
    z83
  ];
  "configs/hp2/haslo-root.age".publicKeys = [
    legion
    hp2
  ];
  "configs/hp1/haslo-root.age".publicKeys = [
    legion
    hp1
  ];
  "secrets/k3s-token.age".publicKeys = [ legion ] ++ cluster;

}
