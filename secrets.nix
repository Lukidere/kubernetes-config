let
  legion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEX1Ja0Tkcp/bW75Y12iwZKMAo/6VFwkvUJQ24qN4kF koniecznyrad@gmail.com";
  z83 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQJUff38bZ+3JpNGjh3PLERyp1/T4VI9BStV8pq1+Qh root@z83";
  hp1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/NeRhYJ2nuj56w6DeJP7aS9ANKNvLjw/mi6wM36xs4 root@hp-1";
  hp2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9ByB5XJKZhYSau8SAJ/AOs2pl2Rm7eOkmIEvWphTJX root@hp-2";
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
