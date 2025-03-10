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

      wal_level = 'replica'
      max_wal_senders = 10
      max_replication_slots = 10
      hot_standby = on
    '';

    environment.etc."postgresql-nix/pg_hba.conf".text = ''
      # urborg.geosurge.ai
      hostssl all           replicant 147.93.87.234/32 scram-sha-256
      hostssl all           replicant 2a02:4780:f:db50::1/128 scram-sha-256
      hostssl replication   replicant 147.93.87.234/32 scram-sha-256
      hostssl replication   replicant 2a02:4780:f:db50::1/128 scram-sha-256

      local   all   all                  trust

      # The world
      hostssl all   fran    0.0.0.0/0      scram-sha-256
      hostssl all   fran    ::/0           scram-sha-256
      hostssl all   sweater 0.0.0.0/0      scram-sha-256
      hostssl all   sweater ::/0           scram-sha-256
      hostssl all   fbthlp  0.0.0.0/0      scram-sha-256
      hostssl all   fbthlp  ::/0           scram-sha-256
    '';

  };

}
