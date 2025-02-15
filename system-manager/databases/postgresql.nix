{ pkgs, ... }:

{

  config.environment.systemPackages = [
    pkgs.postgresql
  ];

  # Define an independent PostgreSQL service named "postgresql-nix"
  config.systemd.services."postgresql-nix" = {
    enable = true;
    description = "Independent PostgreSQL database server (nix instance)";
    after = [ "network.target" ];
    wantedBy = [ "system-manager.target" ];
    serviceConfig = {
      User = "postgres";
      RuntimeDirectory = "postgresql-nix";
      RuntimeDirectoryMode = "0755";
      ExecStartPre = "/bin/sh -c 'mkdir -p /var/lib/postgresql/nix-data; if [ ! -f /var/lib/postgresql/nix-data/PG_VERSION ]; then ${pkgs.postgresql}/bin/initdb -D /var/lib/postgresql/nix-data; fi'";
      ExecStart = "${pkgs.postgresql}/bin/postgres -D /var/lib/postgresql/nix-data -c config_file=/etc/postgresql-nix/postgresql.conf";
      Restart = "on-failure";
    };
  };

  # A bootstrap service to create a default user and a "catchall" database.
  # We create "yogi" user after Yogi Berra, the legendary baseball catcher.
  config.systemd.services.postgresql-bootstrap = {
    enable = true;
    description = "Bootstrap PostgreSQL: create default user and catchall database (debug enabled)";
    after = [ "postgresql-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStartPre = "/bin/sh -c 'set -x; ${pkgs.postgresql}/bin/psql -h /var/run/postgresql-nix -tc \"DO \\$DELIM\\$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '\\''yogi'\\'') THEN CREATE ROLE yogi WITH LOGIN CREATEDB SUPERUSER; END IF; END \\$DELIM\\$;\"'";
      ExecStart = "/bin/sh -c 'set -x; if [ -z \"$(${pkgs.postgresql}/bin/psql -h /var/run/postgresql-nix -Atc \"SELECT 1 FROM pg_database WHERE datname = '\\''catchall'\\''\")\" ]; then ${pkgs.postgresql}/bin/psql -h /var/run/postgresql-nix -c \"CREATE DATABASE catchall OWNER yogi\"; fi'";
    };
  };

}
