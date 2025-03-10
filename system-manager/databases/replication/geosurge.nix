{ pkgs, config, ... }:

{
  config.environment.systemPackages = [ pkgs.postgresql ];

  config.systemd.services."pg-basebackup-geosurge" = {
    enable = true;
    description = "Daily pg_basebackup for geosurge replication";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "postgres";
      Type = "simple";
      RuntimeDirectory = "postgresql-replica-geosurge-cold";
      RuntimeDirectoryMode = "0755";
      ExecStart = ''
        /bin/sh -c "D=/var/run/postgresql-replica-geosurge-cold && mkdir -p $D && ${pkgs.postgresql}/bin/pg_basebackup -d 'postgres://replicant:canttouchthis@crawlspace.memorici.de/geosurge?sslmode=require' -D $D -S urborg_daily_slot -P -v --wal-method=stream --write-recovery-conf && \
        cp -rv $D/ /var/lib/postgresql/geosurge.today && \
        rm -rf /var/lib/postgresql/geosurge.yesterday && \
        mv /var/lib/postgresql/geosurge.today /var/lib/postgresql/geosurge.yesterday"
      '';
    };
  };

  config.systemd.services."postgresql-replica-geosurge" = {
    enable = true;
    description = "PostgreSQL replication service (hot standby) for geosurge";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "postgres";
      RuntimeDirectory = "postgresql-replica-geosurge";
      RuntimeDirectoryMode = "0755";
      TimeoutStartSec = 666;
      ExecStartPre = "/bin/sh -c 'if [ ! -f /var/lib/postgresql/geosurge_replica/PG_VERSION ]; then mkdir -p /var/lib/postgresql/geosurge_replica && echo 1 && chmod 700 /var/lib/postgresql/geosurge_replica && echo 2 && ${pkgs.postgresql}/bin/pg_basebackup -d 'postgres://replicant:canttouchthis@crawlspace.memorici.de/geosurge?sslmode=require' -D /var/lib/postgresql/geosurge_replica -S urborg_slot -P -v --wal-method=stream --write-recovery-conf && echo 3 ; fi'";
      ExecStart = "${pkgs.postgresql}/bin/postgres -D /var/lib/postgresql/geosurge_replica -c config_file=/etc/postgresql-nix/geosurge_replica.conf";
      Restart = "on-failure";
    };
  };

   config.systemd.timers."pg-basebackup-geosurge" = {
    enable = true;
    description = "Daily timer for pg_basebackup for geosurge replication";
    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      Persistent = true;
      unit = "pg-basebackup-geosurge.service";
    };
    wantedBy = [ "timers.target" ];
  };
}
