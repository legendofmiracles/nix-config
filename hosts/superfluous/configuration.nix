{ config, lib, pkgs, options, ... }:

let theme = import ../../config/theme.nix;
in
{
  boot = {
    /*
      NOTE: replace this with your desired kernel

      If you're not me or a XanMod kernel maintainer, use pkgs.linuxPackages_xanmod instead.
    */
    kernelPackages = pkgs.kernel.linuxPackages_xanmod;

    kernelParams = [
      "ro"
      "quiet"
      "splash"
      "mitigations=off"
      "acpi_backlight=vendor"
      "nmi_watchdog=0"
      "systemd.watchdog-device=/dev/watchdog"
    ];

    kernel.sysctl = {
      "fs.file-max" = 2097152;
      "kernel.printk" = "3 3 3 3";
      "kernel.sched_migration_cost_ns" = 5000000;
      "kernel.unprivileged_userns_clone" = 1;
      "net.core.default_qdisc" = "fq_pie";
      "vm.dirty_ratio" = 60;
      "vm.dirty_background_ratio" = 2;
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 75;
    };

    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "max";
      };
    };
  };

  console =
    let
      normal = with theme.colors; [ c0 c1 c2 c3 c4 c5 c6 c7 ];
      bright = with theme.colors; [ c8 c9 c10 c11 c12 c13 c14 c15 ];
    in
    {
      colors = normal ++ bright;
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

  hardware = {
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };

    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
    };
  };

  imports = [
    ./hardware-configuration.nix
    ../../modules/services/xcompmgr.nix
    ../../modules/programs/river.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    /*
      NOTE: This isn't found in https://search.nixos.org/options.

      Here's the warning that came with it:

      "Please note that NixOS assumes all over the place that shell to be Bash,
      so override the default setting only if you know exactly what you're doing."
    */
    binsh = "${pkgs.mksh}/bin/mksh";
    pathsToLink = [ "/share/zsh" ];

    sessionVariables = with pkgs; {
      LD_PRELOAD = "/etc/nixos/config/ld-preload-xcreatewindow.so";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    systemPackages = with pkgs; [
      alsaTools
      alsaUtils
      brightnessctl
      caffeine-ng
      coreutils
      curl
      dash
      envsubst
      fd
      file
      git
      glxinfo
      gnome3.nautilus
      gxmessage
      hacksaw
      haskell-language-server
      hsetroot
      imagemagick
      jp2a
      jq
      libtool
      libva-utils
      lm_sensors
      notify-desktop
      ntfs3g
      pandoc
      pantheon.elementary-files
      pavucontrol
      pciutils
      psmisc
      pulseaudio
      ripgrep
      shellcheck
      shotgun
      subversion
      unrar
      unzip
      util-linux
      wget
      xarchiver
      xclip
      xdo
      xdotool
      xidlehook
      xmonad-log
      xorg.xdpyinfo
      xorg.xsetroot
      xorg.xkill
      xorg.xwininfo
      xwallpaper
      zip
    ];
  };

  fonts = {
    fonts = with pkgs; [
      cozette
      curie
      dejavu_fonts
      emacs-all-the-icons-fonts
      etBook
      fantasque-sans-mono
      inter
      iosevka
      mplus-outline-fonts
      nerdfonts
      nur.repos.fortuneteller2k.iosevka-ft-bin
      /*
        TODO: use only when current is outdated
        iosevka-ft
      */
      roboto-mono
      sarasa-gothic
      scientifica
      symbola
      terminus_font
      twemoji-color-font
      xorg.fontbh100dpi
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [
          "Sarasa Gothic C"
          "Sarasa Gothic J"
          "Sarasa Gothic K"
        ];

        sansSerif = [
          "Sarasa Gothic C"
          "Sarasa Gothic J"
          "Sarasa Gothic K"
        ];

        monospace = [
          "Iosevka FT"
          "Iosevka Nerd Font"
          "Sarasa Mono C"
          "Sarasa Mono J"
          "Sarasa Mono K"
        ];

        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };

  networking = {
    dhcpcd.enable = false;
    hostName = "superfluous";

    interfaces = {
      eno1.useDHCP = true;
      wlan0.useDHCP = true;
    };

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];

    networkmanager = {
      enable = true;
      dns = "none";
      wifi.backend = "iwd";
    };

    useDHCP = false;
    wireless.iwd.enable = true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  programs = {
    bash = {
      promptInit = ''eval "$(${pkgs.starship}/bin/starship init bash)"'';
      interactiveShellInit = ''export HISTFILE=$HOME/.config/.bash_history'';
    };

    command-not-found.enable = false;
    dconf.enable = true;
    slock.enable = true;

    sway = {
      enable = false;
      wrapperFeatures.gtk = true;

      extraPackages = with pkgs; [
        swaylock
        swayidle
        swaybg
        wl-clipboard
        mako
        brightnessctl
        grim
        slurp
        sway-contrib.grimshot
        waybar
        wofi
      ];
    };

    qt5ct.enable = true;

    xss-lock = {
      enable = true;
      lockerCommand = "${config.security.wrapperDir}/slock";
    };
  };

  security = {
    protectKernelImage = true;
    rtkit.enable = true;
    sudo.wheelNeedsPassword = false;

    doas = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  services = {
    auto-cpufreq.enable = true;

    chrony = {
      enable = true;

      servers = [
        "ntp.pagasa.dost.gov.ph"
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };

    irqbalance.enable = true;
    journald.extraConfig = lib.mkForce "";

    openssh = {
      enable = true;
      gatewayPorts = "yes";
      permitRootLogin = "yes";
    };

    picom = {
      enable = true;
      refreshRate = 60;
      # experimentalBackends = config.services.picom.backend == "glx";
      backend = "glx";
      vSync = true;

      settings = import ./config/picom-settings.nix;
    };

    pipewire = {
      enable = true;
      socketActivation = false;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      jack.enable = true;
      pulse.enable = true;

      config = import ./config/pipewire;
      media-session.config = import ./config/pipewire/media-session.nix;
    };

    tlp.enable = true;
    upower.enable = true;

    udev.extraRules = ''
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';

    xserver = {
      enable = true;

      displayManager = {
        sddm.enable = config.services.xserver.enable;
        defaultSession = "none+xmonad";
      };

      extraConfig = import ./config/xorg.nix;
      useGlamor = true;

      windowManager = {
        xmonad = with pkgs; {
          enable = true;
          config = import ./config/xmonad.nix { inherit config pkgs theme; };
          extraPackages = hpkgs: with hpkgs; [ dbus xmonad-contrib ];

          ghcArgs = [
            "-O2"
            "-fasm-shortcutting"
            "-fdicts-cheap"
            "-fdicts-strict"
            "-funfolding-use-threshold=16"
            "-fspecialise-aggressively"
            "-fblock-layout-weightless"
            "-feager-blackholing"
            "-fexpose-all-unfoldings"
            "-fregs-iterative"
            "-fspec-constr-keen"
            "-fstatic-argument-transformation"
            "-funbox-strict-fields"
            "-flate-dmd-anal"
            "-fignore-interface-pragmas"
            "-ffun-to-thunk"
            "-fexcess-precision"
            "-optc-O3"
            "-optc-ffast-math"
          ];
        };
      };

      layout = "us";

      libinput = {
        enable = true;
        mouse.accelProfile = "flat";
        touchpad.naturalScrolling = true;
      };
    };
  };

  system = {
    userActivationScripts = {
      reloadWallpaper.text =
        let
          xwallpaperFlag = if theme.colors.tiledWallpaper then "--tile" else "--zoom";
        in
        if config.services.xserver.enable then
          "[ $DISPLAY ] && ${pkgs.xwallpaper}/bin/xwallpaper ${xwallpaperFlag} ${theme.colors.wallpaper} || ${pkgs.coreutils}/bin/echo 'skipping...'"
        else
          "${pkgs.coreutils}/bin/echo 'skipping because on wayland...'";

      reloadXMonad.text =
        if config.services.xserver.enable && config.services.xserver.windowManager.xmonad.enable then
          "[ $DISPLAY ] && ${pkgs.xmonad-with-packages}/bin/xmonad --restart || echo 'not in xmonad, skipping...' || ${pkgs.coreutils}/bin/echo 'skipping...'"
        else
          "${pkgs.coreutils}/bin/echo 'skipping because on wayland...'";
    };

    /*
      NOTE: DO NOT CHANGE THIS IF YOU DON'T KNOW WHAT YOU'RE DOING.

      Only change this if you are ABSOLUTELY 100% SURE that you don't have stateful data.
    */
    stateVersion = "21.05";
  };

  systemd = {
    extraConfig = "RebootWatchdogSec=5";
    services.rtkit-daemon = import ./services/rtkit-daemon.nix { inherit pkgs; };

    user.services = {
      pipewire.wantedBy = [ "default.target" ];
      pipewire-pulse.wantedBy = [ "default.target" ];
      xidlehook = import ./services/xidlehook.nix { inherit config lib pkgs; };
    };
  };

  time.timeZone = "Asia/Manila";

  users.users.fortuneteller2k = {
    isNormalUser = true;
    home = "/home/fortuneteller2k";
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "realtime"
    ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
