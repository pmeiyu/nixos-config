# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FF8B-5F2E";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/956ade2b-027b-48e2-82f7-b9591186d7e2";
    allowDiscards = true;
    fallbackToPassword = true;
    keyFile = "/dev/disk/by-partuuid/a40374be-2443-4c01-ae9d-159f4906d127";
    keyFileSize = 1024;
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2d65633a-a5d4-48b9-aef8-e26fef389f26";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  boot.initrd.luks.devices."st-1" = {
    device = "/dev/disk/by-uuid/8c48718b-5d06-477e-9797-802f9f6cc96a";
    fallbackToPassword = true;
    keyFile = "/dev/disk/by-partuuid/a40374be-2443-4c01-ae9d-159f4906d127";
    keyFileSize = 1024;
  };
  boot.initrd.luks.devices."wd-1" = {
    device = "/dev/disk/by-uuid/46d88fb9-3244-40f6-b2fb-8d3a51dc74fa";
    fallbackToPassword = true;
    keyFile = "/dev/disk/by-partuuid/a40374be-2443-4c01-ae9d-159f4906d127";
    keyFileSize = 1024;
  };
  boot.initrd.luks.devices."wd-2" = {
    device = "/dev/disk/by-uuid/4a0ad149-632c-495d-943c-3bb02337fd3b";
    fallbackToPassword = true;
    keyFile = "/dev/disk/by-partuuid/a40374be-2443-4c01-ae9d-159f4906d127";
    keyFileSize = 1024;
  };
  fileSystems."/srv/store" = {
    device = "/dev/disk/by-uuid/1c78a577-61a2-41d5-9cf5-fc5e5085d9a7";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  swapDevices = [ ];
}
