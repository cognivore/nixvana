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
      hostssl all all 202:9557:aae7:88f8:cfcc:1b63:3dce:7475/128 scram-sha-256

      local   all   all                  trust

      hostssl all   all   0.0.0.0/0      scram-sha-256
      hostssl all   all   ::/0           scram-sha-256
    '';

  };

}
