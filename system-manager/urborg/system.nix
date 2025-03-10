{ pkgs, ... }:

{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = with pkgs; [
      glibcLocales
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

    environment.etc."postgresql-nix/postgresql.conf".text = ''
      listen_addresses = '*'
      unix_socket_directories = '/var/run/postgresql-nix'

      ssl = on
      ssl_cert_file = '/etc/ssl/postgresql-nix/selfsigned.crt'
      ssl_key_file = '/etc/ssl/postgresql-nix/selfsigned.key'
      ssl_ca_file = '/etc/ssl/postgresql-nix/selfsigned.crt'
      ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
      ssl_prefer_server_ciphers = on

      hba_file = '/etc/postgresql-nix/pg_hba.conf'

    '';

    environment.etc."postgresql-nix/pg_hba.conf".text = ''
      local   all   all                  trust

      # The world
      hostssl all   fran    0.0.0.0/0      scram-sha-256
      hostssl all   fran    ::/0           scram-sha-256
      hostssl all   sweater 0.0.0.0/0      scram-sha-256
      hostssl all   sweater ::/0           scram-sha-256
      hostssl all   fbthlp  0.0.0.0/0      scram-sha-256
      hostssl all   fbthlp  ::/0           scram-sha-256
    '';

    environment.etc."postgresql-nix/geosurge_replica.conf".text = ''

      hot_standby = on
      primary_conninfo = 'host=crawlspace.memorici.de port=5432 user=replicant password=canttouchthis sslmode=require'
      primary_slot_name = 'urborg_slot'
      port = 5678

      hba_file = '/etc/postgresql-nix/pg_hba.conf'
      unix_socket_directories = '/var/run/postgresql-replica-geosurge'

      listen_addresses = '*'

      ssl = on
      ssl_cert_file = '/etc/ssl/postgresql-nix/selfsigned.crt'
      ssl_key_file = '/etc/ssl/postgresql-nix/selfsigned.key'
      ssl_ca_file = '/etc/ssl/postgresql-nix/selfsigned.crt'
      ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
      ssl_prefer_server_ciphers = on

    '';

  };

}
