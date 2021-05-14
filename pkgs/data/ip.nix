rec {
  v4.gfwlist = v4.google ++ v4.telegram ++ v4.twitter ++ v4.wikimedia;
  v6.gfwlist = v6.google ++ v6.telegram ++ v6.twitter ++ v6.wikimedia;

  v4.slow = v4.emacs;
  v6.slow = v6.emacs;

  # Emacs
  v4.emacs = [
    # elpa.gnu.org
    "209.51.188.89"

    # melpa.org
    "178.128.185.1"

    # orgmode.org
    "45.77.159.66"
  ];

  v6.emacs = [ ];

  # Google
  v4.google = [
    "35.190.247.0/24"
    "35.191.0.0/16"
    "64.233.160.0/19"
    "66.102.0.0/20"
    "66.249.80.0/20"
    "72.14.192.0/18"
    "74.114.24.0/21"
    "74.125.0.0/16"
    "108.177.8.0/21"
    "108.177.96.0/19"
    "130.211.0.0/22"
    "136.112.0.0/12"
    "172.217.0.0/19"
    "172.217.128.0/19"
    "172.217.160.0/20"
    "172.217.192.0/19"
    "172.217.224.0/19"
    "172.217.32.0/20"
    "172.253.112.0/20"
    "172.253.56.0/21"
    "173.194.0.0/16"
    "208.81.188.0/22"
    "209.85.128.0/17"
    "216.239.32.0/19"
    "216.58.192.0/19"
  ];

  v6.google = [
    "2001:4860:4000::/36"
    "2404:6800:4000::/36"
    "2607:f8b0:4000::/36"
    "2800:3f0:4000::/36"
    "2a00:1450:4000::/36"
    "2c0f:fb50:4000::/36"
  ];

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
