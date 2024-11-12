{ pkgs, ... }:

{
  config.systemd.services.prometheus = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.prometheus}/bin/prometheus --config.file=/etc/prometheus/prometheus.yml";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  config.systemd.services.node_exporter = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.prometheus-node-exporter}/bin/node_exporter";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
