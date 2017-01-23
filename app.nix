{ config, lib, pkgs, ... }:

with lib; # provides mkOption, types, ...

let
  # this env builds the python interpreter that you want to run your app against
  env = pkgs.python27.withPackages (ps: [ ps.flask ]);

  # fetch the source from github
  src = pkgs.fetchFromGitHub {
    owner = "pradeepchhetri";
    repo = "hello-world";
    rev = "master";
    sha256 = "1c79svqzp1q740fbprwidsiws3dsiyz3afb039h7q6839b7fj8fw";
  };

  # pull the values set for the configuration options
  cfg = config.services.hello-world;

in {
  # define the options that we support
  options = {
    services.hello-world = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable example web app";
      };

      port = mkOption {
        type = types.int;
        default = 5000;
        description = "Network port to listen at";
      };

      host = mkOption {
        type = types.string;
        default = "127.0.0.1";
        description = "Network interface to bind to";
      };
    };
  };

  # systemd configuration
  config = mkIf cfg.enable { # only activate service if enabled
    systemd.services.hello-world = {
      description = "Hello world web app";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      environment.FLASK_APP = "${src}/hello.py";
      script = "${env}/bin/flask run -p ${toString cfg.port} -h ${cfg.host}";
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
