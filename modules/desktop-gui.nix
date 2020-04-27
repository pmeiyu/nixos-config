{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.desktop.gui;
in {
  options = {
    my.desktop.gui = {
      enable = mkEnableOption "Enable Graphical configurations.";
    };
  };

  config = mkIf cfg.enable {
    fonts.fonts = with pkgs; [
      dejavu_fonts
      font-awesome
      material-icons
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      powerline-fonts
      source-han-sans-simplified-chinese
      source-han-sans-traditional-chinese
      source-han-serif-simplified-chinese
      source-han-serif-traditional-chinese
      wqy_microhei
    ];
    fonts.fontconfig.defaultFonts = {
      monospace = [ "DejaVu Sans Mono" "Source Han Mono" ];
      sansSerif = [ "Source Han Sans" "Noto Sans" ];
      serif = [ "Source Han Serif" "Noto Serif" ];
    };

    i18n.inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ rime ];
    };

    environment.systemPackages = with pkgs; [
      brightnessctl
      nixfmt

      evince
      firefox-esr
      grim
      imv
      keepassxc
      mako
      mpv
      rofi
      slurp
      termite
      vlc
      waybar
      wl-clipboard
    ];

    ## Services

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    programs.sway = {
      enable = true;
      extraPackages = with pkgs; [ swaybg swayidle swaylock xwayland ];
      extraSessionCommands = ''
        # Load environment variables from login shell.
        xsession_tmp=`mktemp /tmp/xsession-env-XXXXXX`
        zsh --login -c "/bin/sh -c 'export -p' > $xsession_tmp"
        source $xsession_tmp
        rm -f $xsession_tmp
      '';
    };

    services.gnome3.core-os-services.enable = true;
    services.gvfs.enable = true;
    programs.seahorse.enable = true;

    services.pipewire.enable = true;
  };
}
