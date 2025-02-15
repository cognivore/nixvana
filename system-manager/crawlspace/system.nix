{ pkgs, ... }:

{
  config = {
    # Kali is basically Ubuntu
    system-manager.allowAnyDistro = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = with pkgs; [
      postgresql
    ];

    environment.etc."prometheus/prometheus.yml".text = ''
      scrape_configs:
        - job_name: 'node'
          static_configs:
            - targets: ['localhost:9100']
        - job_name: "zhr_devs"
          static_configs:
            - targets: ['localhost:4164']
        - job_name: "zhr_rootrunner"
          static_configs:
            - targets: ['localhost:4002']
        - job_name: "zhr_rootrunner_staging"
          static_configs:
            - targets: ['localhost:4001']
    '';

    # Configuration for the independent PostgreSQL instance.
    environment.etc."postgresql-nix/postgresql.conf".text = ''
      listen_addresses = 'localhost'
      unix_socket_directories = '/var/run/postgresql-nix'
    '';

    environment.etc."postgresql-nix/pg_hba.conf".text = ''
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            md5
      host    all             all             ::1/128                 md5
    '';
  };

}
