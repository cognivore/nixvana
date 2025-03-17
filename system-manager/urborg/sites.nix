{ config, lib, pkgs, ... }:

{
  config = {
    environment.etc = {
      "caddy/Caddyfile".text = ''
        {
          email jons@geosurge.ai
          admin 127.0.0.1:8313
        }

        import /etc/caddy/sites-enabled/*
      '';

      "caddy/sites-enabled/urborg.geosurge.ai.conf".text = ''
        urborg.geosurge.ai {
          reverse_proxy http://127.0.0.1:53972
        }
      '';
    };

    systemd.services.caddy = {
      enable = true;
      serviceConfig = {
        ExecStart = "${pkgs.caddy}/bin/caddy run --config /etc/caddy/Caddyfile";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
