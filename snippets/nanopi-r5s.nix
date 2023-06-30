{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";


  ## Boot loader

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.configurationLimit = 2;
  boot.loader.timeout = 1;


  ## Kernel

  hardware.deviceTree.name = "rockchip/rk3568-nanopi-r5s.dtb";

  boot.kernelParams = [
    "console=tty1"
    "console=ttyS2,115200n8"
    "console=both"
    "earlyprintk"

    # Fix NVME bug
    # https://github.com/pyavitz/debian-image-builder/issues/56
    "pcie_aspm=off"
  ];

  # Note: Linux kernel compilation time on NanoPi-R5S RK3568 @2.0GHz
  # Default config: 14 hours
  # Following config: 6 hours

  boot.kernelPackages = assert lib.versionAtLeast pkgs.linux_latest.version "6.4";
    pkgs.linuxKernel.packagesFor (pkgs.linux_latest.override {
      structuredExtraConfig = with lib.kernel; {
        PCIE_ROCKCHIP_DW_HOST = yes;

        # Platform selection
        ARCH_ACTIONS = no;
        ARCH_SUNXI = no;
        ARCH_ALPINE = no;
        ARCH_APPLE = no;
        ARCH_BCM = no;
        ARCH_BCM2835 = no;
        ARCH_BCM_IPROC = no;
        ARCH_BCMBCA = no;
        ARCH_BRCMSTB = no;
        ARCH_BERLIN = no;
        ARCH_EXYNOS = no;
        ARCH_K3 = no;
        ARCH_LG1K = no;
        ARCH_HISI = no;
        ARCH_KEEMBAY = no;
        ARCH_MEDIATEK = no;
        ARCH_MESON = no;
        ARCH_MVEBU = no;
        ARCH_NXP = no;
        ARCH_LAYERSCAPE = no;
        ARCH_MXC = no;
        ARCH_S32 = no;
        ARCH_NPCM = no;
        ARCH_QCOM = no;
        ARCH_REALTEK = no;
        ARCH_RENESAS = no;
        ARCH_ROCKCHIP = yes;
        ARCH_SEATTLE = no;
        ARCH_INTEL_SOCFPGA = no;
        ARCH_SYNQUACER = no;
        ARCH_TEGRA = no;
        ARCH_TESLA_FSD = no;
        ARCH_SPRD = no;
        ARCH_THUNDER = no;
        ARCH_THUNDER2 = no;
        ARCH_UNIPHIER = no;
        ARCH_VEXPRESS = no;
        ARCH_VISCONTI = no;
        ARCH_XGENE = no;
        ARCH_ZYNQMP = no;


        # Ethernet

        NET_VENDOR_3COM = no;
        NET_VENDOR_8390 = no;
        NET_VENDOR_ADAPTEC = no;
        NET_VENDOR_ADI = no;
        NET_VENDOR_AGERE = no;
        NET_VENDOR_ALACRITECH = no;
        NET_VENDOR_ALTEON = no;
        NET_VENDOR_AMAZON = no;
        NET_VENDOR_AMD = no;
        NET_VENDOR_AQUANTIA = no;
        NET_VENDOR_ARC = no;
        NET_VENDOR_ASIX = no;
        NET_VENDOR_ATHEROS = no;
        NET_VENDOR_BROADCOM = no;
        NET_VENDOR_BROCADE = no;
        NET_VENDOR_CADENCE = no;
        NET_VENDOR_CAVIUM = no;
        NET_VENDOR_CHELSIO = no;
        NET_VENDOR_CISCO = no;
        NET_VENDOR_CORTINA = no;
        NET_VENDOR_DAVICOM = no;
        NET_VENDOR_DEC = no;
        NET_VENDOR_DLINK = no;
        NET_VENDOR_EMULEX = no;
        NET_VENDOR_ENGLEDER = no;
        NET_VENDOR_EZCHIP = no;
        NET_VENDOR_FUJITSU = no;
        NET_VENDOR_FUNGIBLE = no;
        NET_VENDOR_GOOGLE = no;
        NET_VENDOR_HISILICON = no;
        NET_VENDOR_HUAWEI = no;
        NET_VENDOR_I825XX = no;
        NET_VENDOR_INTEL = no;
        NET_VENDOR_LITEX = no;
        NET_VENDOR_MARVELL = no;
        NET_VENDOR_MELLANOX = no;
        NET_VENDOR_MICREL = no;
        NET_VENDOR_MICROCHIP = no;
        NET_VENDOR_MICROSEMI = no;
        NET_VENDOR_MICROSOFT = no;
        NET_VENDOR_MYRI = no;
        NET_VENDOR_NATSEMI = no;
        NET_VENDOR_NETERION = no;
        NET_VENDOR_NETRONOME = no;
        NET_VENDOR_NI = no;
        NET_VENDOR_NVIDIA = no;
        NET_VENDOR_OKI = no;
        NET_VENDOR_PACKET_ENGINES = no;
        NET_VENDOR_PENSANDO = no;
        NET_VENDOR_QLOGIC = no;
        NET_VENDOR_QUALCOMM = no;
        NET_VENDOR_RDC = no;
        NET_VENDOR_REALTEK = yes; # LAN kernel driver r8169
        NET_VENDOR_RENESAS = no;
        NET_VENDOR_ROCKER = no;
        NET_VENDOR_SAMSUNG = no;
        NET_VENDOR_SEEQ = no;
        NET_VENDOR_SILAN = no;
        NET_VENDOR_SIS = no;
        NET_VENDOR_SMSC = no;
        NET_VENDOR_SOCIONEXT = no;
        NET_VENDOR_SOLARFLARE = no;
        NET_VENDOR_STMICRO = yes; # WAN kernel driver dwmac-rk
        NET_VENDOR_SUN = no;
        NET_VENDOR_SYNOPSYS = no;
        NET_VENDOR_TEHUTI = no;
        NET_VENDOR_TI = no;
        NET_VENDOR_VERTEXCOM = no;
        NET_VENDOR_VIA = no;
        NET_VENDOR_WANGXUN = no;
        NET_VENDOR_WIZNET = no;
        NET_VENDOR_XILINX = no;
        NET_VENDOR_XIRCOM = no;

        # WLAN

        WLAN_VENDOR_ADMTEK = no;
        WLAN_VENDOR_ATH = no;
        WLAN_VENDOR_ATMEL = no;
        WLAN_VENDOR_BROADCOM = no;
        WLAN_VENDOR_CISCO = no;
        WLAN_VENDOR_INTEL = no;
        WLAN_VENDOR_INTERSIL = no;
        WLAN_VENDOR_MARVELL = no;
        WLAN_VENDOR_MEDIATEK = no;
        WLAN_VENDOR_MICROCHIP = no;
        WLAN_VENDOR_PURELIFI = no;
        WLAN_VENDOR_QUANTENNA = no;
        WLAN_VENDOR_RALINK = no;
        WLAN_VENDOR_REALTEK = no;
        WLAN_VENDOR_RSI = no;
        WLAN_VENDOR_SILABS = no;
        WLAN_VENDOR_ST = no;
        WLAN_VENDOR_TI = no;
        WLAN_VENDOR_ZYDAS = no;


        CHROME_PLATFORMS = lib.mkForce no;
        SURFACE_PLATFORMS = no;

        ACPI = no;
        BT = no;
        CAN = no;
        DRM_AMDGPU = no;
        DRM_NOUVEAU = no;
        DRM_RADEON = no;
        FPGA = no;
        IIO = no;
        INFINIBAND = lib.mkForce no;
        INPUT_TOUCHSCREEN = no;
        MTD = no;
        NFC = no;
        SOUND = no;
        SOUNDWIRE = no;
      };
    });

  boot.initrd.availableKernelModules = [
    # MMC
    "dw_mmc_rockchip"
    "sdhci_of_dwcmshc"

    # NVME
    "nvme"
    "phy_rockchip_snps_pcie3"
  ];


  # Network

  systemd.network.links."10-wan0" = {
    matchConfig = {
      Path = "platform-fe2a0000.ethernet";
    };
    linkConfig = {
      Name = "wan0";
      MACAddress = "b6:55:82:2c:10:00";
    };
  };

  systemd.network.links."10-lan1" = {
    matchConfig = {
      Path = "platform-3c0000000.pcie-pci-0000:01:00.0";
    };
    linkConfig = {
      Name = "lan1";
      MACAddress = "b6:55:82:2c:20:01";
    };
  };

  systemd.network.links."10-lan2" = {
    matchConfig = {
      Path = "platform-3c0400000.pcie-pci-0001:01:00.0";
    };
    linkConfig = {
      Name = "lan2";
      MACAddress = "b6:55:82:2c:20:02";
    };
  };
}
