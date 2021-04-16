{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.river;
in
{
  options.programs.river = {
    enable = mkEnableOption "river, a dynamic tiling Wayland compositor";

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        swaylock
        swayidle
        alacritty
        dmenu
        brightnessctl
        wdisplays
      ];
      defaultText = literalExample ''
        with pkgs; [ swaylock swayidle dmenu alacritty brightnessctl wdisplays ];
      '';
      example = literalExample ''
        with pkgs; [
          grim
          waybar
          rofi
        ]
      '';
      description = ''
        Extra packages to be installed system wide.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.head.river ] ++ cfg.extraPackages;
    security.pam.services.swaylock = { };
    hardware.opengl.enable = mkDefault true;
    fonts.enableDefaultFonts = mkDefault true;
    programs.dconf.enable = mkDefault true;
    programs.xwayland.enable = mkDefault true;

    services.xserver.displayManager.session = [
      {
        manage = "window";
        name = "river";
        start = ''
          systemd-cat -t river -- ${pkgs.head.river}/bin/river &
          waitPID=$!
        '';
      }
    ];

    services.greetd.settings = {
      default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${pkgs.head.river}/bin/river";
    };
  };

  meta.maintainers = with lib.maintainers; [ fortuneteller2k ];
}
