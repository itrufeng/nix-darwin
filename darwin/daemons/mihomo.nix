{ pkgs, ... }:

let
  dataDir = "/Library/Application Support/mihomo";
in
{
  system.activationScripts.preActivation.text = ''
    /usr/bin/install -d -o root -g wheel -m 0700 "${dataDir}"
    /usr/bin/install -d -o root -g wheel -m 0700 "${dataDir}/providers"

    sudo chown -R root:admin "${dataDir}"
    sudo chmod -R 750 root:admin "${dataDir}"
  '';

  launchd.daemons.mihomo = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.mihomo}/bin/mihomo"
        "-d"
        dataDir
      ];

      # only enable service when config.yaml exist
      KeepAlive.PathState = {
        "${dataDir}/config.yaml" = true;
      };

      StandardOutPath = "/var/log/mihomo.log";
      StandardErrorPath = "/var/log/mihomo.err.log";
    };
  };
}
