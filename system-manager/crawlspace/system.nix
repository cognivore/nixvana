{ ... }:

{
  config = {
    # Kali is basically Ubuntu
    system-manager.allowAnyDistro = true;

    nixpkgs.hostPlatform = "x86_64-linux";
    environment.etc."prometheus/prometheus.yml".text = ''
      scrape_configs:
        - job_name: 'node'
          static_configs:
            - targets: ['localhost:9100']
        - job_name: "zhr_devs"
          static_configs:
            - targets: ['localhost:4164']
    '';
  };
}