{ callPackage }:

{
  domain = callPackage ./domain { };
  ip = callPackage ./ip { };
}
