{ lib }:

with lib;
let
  isValidData = x: x != "" && !hasPrefix "#" x;
  readLines = file: filter isValidData (splitString "\n" (readFile file));
in
rec {
  v4.private = [
    "10.0.0.0/8"
    "127.0.0.0/8"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16"
  ];

  v6.private = [
    "::1/128"
    "fc00::/7"
    "fe80::/10"
  ];

  v4.china = readLines ./china.v4.txt;

  v4.non-china = readLines ./non-china.v4.txt;

  v4.gfwlist = with v4; google-except-google-cloud
    ++ telegram
    ++ twitter
    ++ wikimedia;
  v6.gfwlist = with v6; google-except-google-cloud
    ++ telegram
    ++ twitter
    ++ wikimedia;

  v4.slow = v4.emacs;
  v6.slow = [ ];

  # Emacs
  v4.emacs = [
    # elpa.gnu.org
    # elpa.nongnu.org
    "209.51.188.89"

    # melpa.org
    "178.128.185.1"
  ];

  # Google
  v4.google = readLines ./google.v4.txt;

  v4.google-cloud = readLines ./google-cloud.v4.txt;

  v4.google-except-google-cloud = readLines ./google-except-google-cloud.v4.txt;

  v6.google = readLines ./google.v6.txt;

  v6.google-cloud = readLines ./google-cloud.v6.txt;

  v6.google-except-google-cloud = readLines ./google-except-google-cloud.v6.txt;

  # Telegram Messenger Network AS62014
  v4.telegram = [
    "91.108.16.0/22"
    "91.108.56.0/23"
    "149.154.168.0/22"
  ];

  v6.telegram = [
    "2001:b28:f23f::/48"
  ];

  # Twitter AS13414
  v4.twitter = [
    "64.63.0.0/18"
    "69.195.128.0/18"
    "104.244.32.0/20"
    "185.45.4.0/22"
    "192.133.76.0/22"
    "199.16.156.0/22"
    "199.59.148.0/22"
    "199.96.56.0/21"
    "202.160.128.0/22"
    "209.237.192.0/19"
  ];

  v6.twitter = [
    "2400:6680::/32"
    "2606:1f80::/32"
    "2a04:9d40::/29"
  ];

  # Wikimedia AS14907
  v4.wikimedia = [
    "91.198.174.0/24"
    "103.102.166.0/24"
    "185.15.56.0/24"
    "185.15.57.0/24"
    "185.15.58.0/23"
    "198.35.26.0/24"
    "198.35.27.0/24"
    "208.80.152.0/23"
    "208.80.154.0/23"
  ];

  v6.wikimedia = [
    "2001:df2:e500::/48"
    "2620:0:860::/48"
    "2620:0:861::/48"
    "2620:0:862::/48"
    "2620:0:863::/48"
    "2a02:ec80::/32"
  ];
}
