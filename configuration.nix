{ config, pkgs, lib, ... }:

{

imports = [ ./app.nix ];

services.hello-world = {
  enable = true;
  port = 80;
  host = "0.0.0.0";
};

}
