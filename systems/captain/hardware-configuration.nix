# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "thunderbolt" "xhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0607-689A";
    fsType = "vfat";
  };


  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/22bdf0a3-bedf-490b-bc22-651fc25dd9d5";
    allowDiscards = true;
    fallbackToPassword = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "compress=zstd:6" "noatime" ];
  };


  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };


  boot.initrd.luks.devices."swap" = {
    device = "/dev/disk/by-uuid/4d4814a8-5893-4cff-b201-73996a1b4c81";
    allowDiscards = true;
    fallbackToPassword = true;
  };

  swapDevices = [{ device = "/dev/mapper/swap"; discardPolicy = "both"; }];
}
