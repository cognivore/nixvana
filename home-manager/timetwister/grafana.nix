{ pkgs, config, ... }:

{
  # Install Grafana
  home.packages = [ pkgs.grafana ];

  # Configure Grafana
  home.file.".config/grafana/grafana.ini".text = ''
    [paths]
    data = "${config.xdg.dataHome}/grafana/data"
    logs = "${config.xdg.dataHome}/grafana/log"
    plugins = "${config.xdg.dataHome}/grafana/plugins"
    provisioning = "${config.xdg.configHome}/grafana/provisioning"

    [server]
    http_port = 5342
    root_url = http://localhost:5342/

    [security]
    admin_user = admin
    admin_password = admin

    [users]
    allow_sign_up = false
  '';

  # Define systemd user service for Grafana
  systemd.user.services.grafana = {
    Unit = {
      Description = "Grafana User Service";
    };
    Service = {
      ExecStart = ''
        ${pkgs.grafana}/bin/grafana server \
          --config=${config.xdg.configHome}/grafana/grafana.ini \
          --homepath=${pkgs.grafana}/share/grafana
      '';
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}