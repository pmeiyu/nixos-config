{ config, lib, pkgs, ... }:

{

  boot.kernelParams = [
    "pcie_acs_override=downstream"
  ];

  boot.kernelPatches = [
    {
      name = "add-acs-override";
      patch = pkgs.fetchurl {
        url =
          "https://aur.archlinux.org/cgit/aur.git/plain/add-acs-overrides.patch?h=linux-vfio";
        sha256 = "0xrzb1klz64dnrkjdvifvi0a4xccd87h1486spvn3gjjjsvyf2xr";
      };
    }
  ];
}
