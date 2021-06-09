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
    "8.8.4.0/24"
    "8.8.8.0/24"
    "8.34.208.0/20"
    "8.35.192.0/20"
    "23.236.48.0/20"
    "23.251.128.0/19"
    "34.64.0.0/10"
    "34.128.0.0/10"
    "35.184.0.0/13"
    "35.192.0.0/14"
    "35.196.0.0/15"
    "35.198.0.0/16"
    "35.199.0.0/17"
    "35.199.128.0/18"
    "35.200.0.0/13"
    "35.208.0.0/12"
    "35.224.0.0/12"
    "35.240.0.0/13"
    "64.15.112.0/20"
    "64.233.160.0/19"
    "66.102.0.0/20"
    "66.249.64.0/19"
    "70.32.128.0/19"
    "72.14.192.0/18"
    "74.114.24.0/21"
    "74.125.0.0/16"
    "104.154.0.0/15"
    "104.196.0.0/14"
    "104.237.160.0/19"
    "107.167.160.0/19"
    "107.178.192.0/18"
    "108.59.80.0/20"
    "108.170.192.0/18"
    "108.177.0.0/17"
    "130.211.0.0/16"
    "136.112.0.0/12"
    "142.250.0.0/15"
    "146.148.0.0/17"
    "162.216.148.0/22"
    "162.222.176.0/21"
    "172.110.32.0/21"
    "172.217.0.0/16"
    "172.253.0.0/16"
    "173.194.0.0/16"
    "173.255.112.0/20"
    "192.158.28.0/22"
    "192.178.0.0/15"
    "193.186.4.0/24"
    "199.36.154.0/23"
    "199.36.156.0/24"
    "199.192.112.0/22"
    "199.223.232.0/21"
    "207.223.160.0/20"
    "208.65.152.0/22"
    "208.68.108.0/22"
    "208.81.188.0/22"
    "208.117.224.0/19"
    "209.85.128.0/17"
    "216.58.192.0/19"
    "216.73.80.0/20"
    "216.239.32.0/19"
  ];

  v6.google = [
    "2001:4860::/32"
    "2404:6800::/32"
    "2404:f340::/32"
    "2600:1900::/28"
    "2607:f8b0::/32"
    "2620:11a:a000::/40"
    "2620:120:e000::/40"
    "2800:3f0::/32"
    "2a00:1450::/32"
    "2c0f:fb50::/32"
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
