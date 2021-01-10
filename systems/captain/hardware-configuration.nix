# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C4C3-3DA2";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/ed0e0e5c-4077-47a7-b9e0-d890737fad08";
    allowDiscards = true;
    fallbackToPassword = true;
  };
  fileSystems."/" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  boot.initrd.luks.devices."swap" = {
    device = "/dev/disk/by-uuid/d118d859-5e79-45d9-9e03-65a428a0ecbb";
    allowDiscards = true;
    fallbackToPassword = true;
  };
  swapDevices = [{ device = "/dev/mapper/swap"; }];
}
