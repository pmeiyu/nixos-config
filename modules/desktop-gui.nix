{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.desktop.gui;
in
{
  options = {
    my.desktop.gui.enable = mkEnableOption "Enable Graphical configurations.";
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
      source-han-mono
      source-han-sans
      source-han-serif
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


    ## Programs

    programs.adb.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl

      alacritty
      evince
      firefox-esr
      grim
      imv
      keepassxc
      mako
      mpv
      networkmanagerapplet
      rofi
      screenkey
      slurp
      sqlitebrowser
      swappy
      termite
      vlc
      waybar
      waypipe
      wev
      wf-recorder
      wl-clipboard
      ydotool
    ];


    ## Services

    services.xserver = {
      enable = true;
      xkbOptions = "ctrl:nocaps";
      videoDrivers = [ "modesetting" ];
    };

    services.xserver.displayManager.gdm = {
      enable = true;
      autoSuspend = mkDefault false;
    };
    services.xserver.windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3status i3lock picom rofi scrot xclip ];
    };
    programs.sway = {
      enable = true;
      extraPackages = with pkgs; [ swaybg swayidle swaylock xwayland ];
      extraSessionCommands = ''
        # Load environment variables from login shell.
        if [ -z "$__USER_PROFILE_SOURCED" ]; then
            xsession_tmp=`mktemp /tmp/xsession-env-XXXXXX`
            zsh --login -c "/bin/sh -c 'export -p' > $xsession_tmp"
            source $xsession_tmp
            rm -f $xsession_tmp
            export __USER_PROFILE_SOURCED=1
        fi
      '';
    };

    services.gnome = {
      core-os-services.enable = true;
      games.enable = false;
    };
    services.gvfs.enable = true;
    programs.seahorse.enable = true;
  };
}
