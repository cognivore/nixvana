{ pkgs, lib, ... }:

let
  dbSecretsJSON = builtins.readFile /home/sweater/github/nixvana/system-manager/crawlspace/database-secrets.json;
  dbSecrets = builtins.fromJSON dbSecretsJSON;
in

{
  ##############################################################################
  # 1. Include PostgreSQL in system packages
  ##############################################################################
  environment.systemPackages = [
    pkgs.postgresql
  ];

  ##############################################################################
  # 2. Main PostgreSQL service (postgresql-nix)
  ##############################################################################
  systemd.services."postgresql-nix" = {
    enable = true;
    description = "Independent PostgreSQL database server (nix instance)";
    after = [ "network.target" ];
    wantedBy = [ "system-manager.target" ];

    serviceConfig = {
      User = "postgres";
      RuntimeDirectory = "postgresql-nix";
      RuntimeDirectoryMode = "0755";

      ExecStartPre = ''
        bash -c "if [ ! -d /var/lib/postgresql/nix-data ]; then
            mkdir -p /var/lib/postgresql/nix-data && chown postgres:postgres /var/lib/postgresql/nix-data;
          fi;
          if [ ! -f /var/lib/postgresql/nix-data/PG_VERSION ]; then
            ${pkgs.postgresql}/bin/initdb -D /var/lib/postgresql/nix-data;
          fi;
          if [ ! -f /var/lib/postgresql/nix-data/server.key ]; then
            echo \"Generating self-signed certificate for PostgreSQL...\";
            openssl req -new -x509 -days 365 -nodes -subj \"/CN=postgres-nix-instance\" \\
              -keyout /var/lib/postgresql/nix-data/server.key \\
              -out /var/lib/postgresql/nix-data/server.crt;
            chown postgres:postgres /var/lib/postgresql/nix-data/server.*;
            chmod 600 /var/lib/postgresql/nix-data/server.key;
          fi"
      '';


      ExecStart = ''
        ${pkgs.postgresql}/bin/postgres \
          -D /var/lib/postgresql/nix-data \
          -c config_file=/etc/postgresql-nix/postgresql.conf
      '';

      Restart = "on-failure";
    };
  };

  ##############################################################################
  # 3. postgresql.conf (hard-coded)
  ##############################################################################
  environment.etc."postgresql-nix/postgresql.conf".text = ''
    listen_addresses = '*'
    unix_socket_directories = '/var/run/postgresql-nix'
    ssl = on
    ssl_cert_file = '/var/lib/postgresql/nix-data/server.crt'
    ssl_key_file  = '/var/lib/postgresql/nix-data/server.key'
  '';

  ##############################################################################
  # 4. pg_hba.conf (hard-coded)
  ##############################################################################
  environment.etc."postgresql-nix/pg_hba.conf".text = ''
    local   all     admin               trust
    hostssl all     all     0.0.0.0/0   scram-sha-256
    hostssl all     all     ::/0        scram-sha-256
  '';

  ##############################################################################
  # 5. /etc/postgresql-nix/initdb.sql generation
  #
  # dbDatabases entries can look like:
  #   {
  #     name = "mydb";
  #     owner = "admin";
  #     readers = [ "someReader" ];
  #     writers = [ "someWriter" ];
  #   }
  #
  # "readers" get SELECT on all public tables, "writers" get SELECT/INSERT/UPDATE/DELETE,
  # plus default privileges for future tables.
  ##############################################################################
  environment.etc."postgresql-nix/initdb.sql".text =
    let
      dbRoles = dbSecrets.dbRoles or [ ];
      dbDatabases = dbSecrets.dbDatabases or [ ];

      # A. Create or update roles
      roleStmts =
        map
          (r: ''
            DO $DELIM$
            BEGIN
              IF NOT EXISTS (
                SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '${r.name}'
              ) THEN
                CREATE ROLE "${r.name}" WITH LOGIN
                  ${if (r.superuser or false) then "SUPERUSER" else ""}
                  ${if (r.createDb  or false) then "CREATEDB" else ""}
                  ENCRYPTED PASSWORD '${r.password}';
              ELSE
                ALTER ROLE "${r.name}" WITH
                  LOGIN
                  ${if (r.superuser or false) then "SUPERUSER" else "NOSUPERUSER"}
                  ${if (r.createDb  or false) then "CREATEDB" else "NOCREATEDB"}
                  ENCRYPTED PASSWORD '${r.password}';
              END IF;
            END
            $DELIM$;
          '')
          dbRoles;

      # B. Create databases if not present, then grants
      dbStmts =
        map
          (db:
            let
              dbName = db.name;
              dbOwner = db.owner;
              readers = db.readers or [ ];
              writers = db.writers or [ ];
            in
            ''
              -- Create DB if missing
              DO $DELIM$
              BEGIN
                IF NOT EXISTS (
                  SELECT 1 FROM pg_database WHERE datname = '${dbName}'
                ) THEN
                  CREATE DATABASE "${dbName}" OWNER "${dbOwner}";
                END IF;
              END
              $DELIM$;

              -- Readers
              ${lib.concatStringsSep "\n\n" (map (reader: ''
                DO $DELIM$
                BEGIN
                  GRANT CONNECT ON DATABASE "${dbName}" TO "${reader}";
                END
                $DELIM$;

                \\c ${dbName}
                DO $DELIM$
                BEGIN
                  GRANT USAGE ON SCHEMA public TO "${reader}";
                  GRANT SELECT ON ALL TABLES IN SCHEMA public TO "${reader}";
                  ALTER DEFAULT PRIVILEGES IN SCHEMA public
                    GRANT SELECT ON TABLES TO "${reader}";
                END
                $DELIM$;

                \\c postgres
              '') readers)}

              -- Writers
              ${lib.concatStringsSep "\n\n" (map (writer: ''
                DO $DELIM$
                BEGIN
                  GRANT CONNECT ON DATABASE "${dbName}" TO "${writer}";
                END
                $DELIM$;

                \\c ${dbName}
                DO $DELIM$
                BEGIN
                  GRANT USAGE ON SCHEMA public TO "${writer}";
                  GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "${writer}";
                  ALTER DEFAULT PRIVILEGES IN SCHEMA public
                    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${writer}";
                END
                $DELIM$;

                \\c postgres
              '') writers)}
            ''
          )
          dbDatabases;

    in
    lib.concatStringsSep "\n\n" (roleStmts ++ dbStmts);

  ##############################################################################
  # 6. postgresql-nix-init service to run initdb.sql
  ##############################################################################
  systemd.services."postgresql-nix-init" = {
    enable = true;
    description = "Apply initdb.sql after postgresql-nix starts (roles & DB creation)";
    after = [ "postgresql-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";

      ExecStart = ''
        set -x
        if [ -s /etc/postgresql-nix/initdb.sql ]; then
          echo "Applying /etc/postgresql-nix/initdb.sql..."
          ${pkgs.postgresql}/bin/psql -h /var/run/postgresql-nix \
            -f /etc/postgresql-nix/initdb.sql postgres
        else
          echo "No /etc/postgresql-nix/initdb.sql or file is empty; skipping."
        fi
      '';
    };
  };
}
