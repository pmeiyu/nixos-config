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

  v4.china-12 = [
    "1.0.0.0/10"
    "1.64.0.0/11"
    "1.112.0.0/12"
    "1.176.0.0/12"
    "1.192.0.0/12"
    "14.0.0.0/11"
    "14.96.0.0/11"
    "14.128.0.0/11"
    "14.192.0.0/11"
    "27.0.0.0/10"
    "27.96.0.0/11"
    "27.128.0.0/11"
    "27.176.0.0/12"
    "27.192.0.0/11"
    "27.224.0.0/12"
    "36.0.0.0/10"
    "36.96.0.0/11"
    "36.128.0.0/10"
    "36.192.0.0/11"
    "36.240.0.0/12"
    "39.0.0.0/12"
    "39.64.0.0/11"
    "39.96.0.0/12"
    "39.128.0.0/10"
    "40.64.0.0/12"
    "40.112.0.0/12"
    "42.0.0.0/12"
    "42.48.0.0/12"
    "42.80.0.0/12"
    "42.96.0.0/11"
    "42.128.0.0/9"
    "43.128.0.0/10"
    "43.224.0.0/11"
    "45.32.0.0/12"
    "45.64.0.0/12"
    "45.112.0.0/12"
    "45.240.0.0/12"
    "47.80.0.0/12"
    "47.96.0.0/11"
    "49.0.0.0/12"
    "49.48.0.0/12"
    "49.64.0.0/11"
    "49.112.0.0/12"
    "49.128.0.0/11"
    "49.208.0.0/12"
    "49.224.0.0/11"
    "52.80.0.0/12"
    "52.128.0.0/12"
    "54.208.0.0/12"
    "58.0.0.0/9"
    "58.128.0.0/11"
    "58.192.0.0/11"
    "58.240.0.0/12"
    "59.32.0.0/11"
    "59.64.0.0/11"
    "59.96.0.0/12"
    "59.144.0.0/12"
    "59.160.0.0/11"
    "59.192.0.0/10"
    "60.0.0.0/11"
    "60.48.0.0/12"
    "60.160.0.0/11"
    "60.192.0.0/10"
    "61.0.0.0/10"
    "61.80.0.0/12"
    "61.128.0.0/10"
    "61.224.0.0/11"
    "62.224.0.0/12"
    "68.64.0.0/12"
    "69.224.0.0/12"
    "71.128.0.0/12"
    "81.64.0.0/12"
    "82.144.0.0/12"
    "94.176.0.0/12"
    "101.0.0.0/9"
    "101.128.0.0/11"
    "101.192.0.0/12"
    "101.224.0.0/11"
    "103.0.0.0/9"
    "103.128.0.0/11"
    "103.160.0.0/12"
    "103.192.0.0/10"
    "106.0.0.0/9"
    "106.224.0.0/12"
    "109.240.0.0/12"
    "110.0.0.0/9"
    "110.144.0.0/12"
    "110.160.0.0/11"
    "110.192.0.0/10"
    "111.0.0.0/10"
    "111.64.0.0/11"
    "111.112.0.0/12"
    "111.128.0.0/10"
    "111.192.0.0/11"
    "111.224.0.0/12"
    "112.0.0.0/9"
    "112.128.0.0/12"
    "112.192.0.0/12"
    "112.224.0.0/11"
    "113.0.0.0/9"
    "113.128.0.0/12"
    "113.192.0.0/10"
    "114.16.0.0/12"
    "114.48.0.0/12"
    "114.64.0.0/10"
    "114.128.0.0/12"
    "114.192.0.0/10"
    "115.16.0.0/12"
    "115.32.0.0/11"
    "115.64.0.0/10"
    "115.144.0.0/12"
    "115.160.0.0/11"
    "115.192.0.0/11"
    "115.224.0.0/12"
    "116.0.0.0/11"
    "116.48.0.0/12"
    "116.64.0.0/11"
    "116.112.0.0/12"
    "116.128.0.0/9"
    "117.0.0.0/9"
    "117.128.0.0/10"
    "118.16.0.0/12"
    "118.64.0.0/10"
    "118.128.0.0/11"
    "118.176.0.0/12"
    "118.192.0.0/10"
    "119.0.0.0/9"
    "119.128.0.0/10"
    "119.224.0.0/11"
    "120.0.0.0/10"
    "120.64.0.0/11"
    "120.128.0.0/12"
    "120.192.0.0/10"
    "121.0.0.0/10"
    "121.64.0.0/11"
    "121.96.0.0/12"
    "121.192.0.0/12"
    "121.224.0.0/11"
    "122.0.0.0/12"
    "122.48.0.0/12"
    "122.64.0.0/10"
    "122.128.0.0/11"
    "122.176.0.0/12"
    "122.192.0.0/12"
    "122.224.0.0/11"
    "123.0.0.0/12"
    "123.48.0.0/12"
    "123.64.0.0/10"
    "123.128.0.0/10"
    "123.192.0.0/12"
    "123.224.0.0/11"
    "124.0.0.0/11"
    "124.32.0.0/12"
    "124.64.0.0/10"
    "124.128.0.0/11"
    "124.160.0.0/12"
    "124.192.0.0/10"
    "125.16.0.0/12"
    "125.32.0.0/11"
    "125.64.0.0/10"
    "125.160.0.0/12"
    "125.208.0.0/12"
    "125.240.0.0/12"
    "128.96.0.0/12"
    "129.16.0.0/12"
    "129.192.0.0/11"
    "132.224.0.0/12"
    "134.160.0.0/12"
    "137.48.0.0/12"
    "139.0.0.0/12"
    "139.128.0.0/10"
    "139.192.0.0/11"
    "139.224.0.0/12"
    "140.64.0.0/12"
    "140.128.0.0/12"
    "140.176.0.0/12"
    "140.192.0.0/10"
    "142.64.0.0/11"
    "144.0.0.0/12"
    "144.48.0.0/12"
    "144.112.0.0/12"
    "144.240.0.0/12"
    "146.48.0.0/12"
    "146.192.0.0/12"
    "148.64.0.0/12"
    "149.32.0.0/12"
    "150.0.0.0/12"
    "150.112.0.0/12"
    "150.128.0.0/11"
    "150.208.0.0/12"
    "150.240.0.0/12"
    "152.96.0.0/12"
    "152.128.0.0/12"
    "153.0.0.0/12"
    "153.32.0.0/12"
    "153.96.0.0/11"
    "154.0.0.0/12"
    "157.0.0.0/11"
    "157.48.0.0/12"
    "157.112.0.0/12"
    "157.144.0.0/12"
    "157.240.0.0/12"
    "158.48.0.0/12"
    "158.64.0.0/12"
    "159.16.0.0/12"
    "159.64.0.0/12"
    "159.224.0.0/12"
    "160.16.0.0/12"
    "160.192.0.0/12"
    "160.224.0.0/12"
    "161.112.0.0/12"
    "161.176.0.0/12"
    "161.192.0.0/12"
    "162.0.0.0/12"
    "162.96.0.0/12"
    "163.0.0.0/12"
    "163.32.0.0/11"
    "163.112.0.0/12"
    "163.128.0.0/12"
    "163.176.0.0/12"
    "163.192.0.0/12"
    "163.224.0.0/12"
    "164.48.0.0/12"
    "166.96.0.0/12"
    "167.128.0.0/12"
    "167.176.0.0/12"
    "167.208.0.0/12"
    "168.160.0.0/12"
    "170.176.0.0/12"
    "171.0.0.0/12"
    "171.32.0.0/12"
    "171.80.0.0/12"
    "171.96.0.0/11"
    "171.208.0.0/12"
    "172.80.0.0/12"
    "175.0.0.0/10"
    "175.64.0.0/11"
    "175.96.0.0/12"
    "175.144.0.0/12"
    "175.160.0.0/11"
    "180.64.0.0/10"
    "180.128.0.0/10"
    "180.192.0.0/11"
    "180.224.0.0/12"
    "182.16.0.0/12"
    "182.32.0.0/11"
    "182.80.0.0/12"
    "182.96.0.0/11"
    "182.128.0.0/11"
    "182.160.0.0/12"
    "182.192.0.0/12"
    "182.224.0.0/11"
    "183.0.0.0/10"
    "183.64.0.0/11"
    "183.128.0.0/9"
    "185.192.0.0/12"
    "188.128.0.0/12"
    "192.48.0.0/12"
    "192.96.0.0/11"
    "192.128.0.0/11"
    "192.192.0.0/12"
    "193.112.0.0/12"
    "198.160.0.0/12"
    "199.208.0.0/12"
    "202.0.0.0/9"
    "202.128.0.0/10"
    "202.192.0.0/12"
    "203.0.0.0/9"
    "203.128.0.0/10"
    "203.192.0.0/11"
    "204.48.0.0/12"
    "210.0.0.0/10"
    "210.64.0.0/11"
    "210.176.0.0/12"
    "210.192.0.0/12"
    "211.64.0.0/11"
    "211.96.0.0/12"
    "211.128.0.0/11"
    "211.160.0.0/12"
    "212.64.0.0/12"
    "212.128.0.0/12"
    "218.0.0.0/11"
    "218.48.0.0/12"
    "218.64.0.0/11"
    "218.96.0.0/12"
    "218.176.0.0/12"
    "218.192.0.0/12"
    "218.240.0.0/12"
    "219.64.0.0/11"
    "219.128.0.0/11"
    "219.208.0.0/12"
    "219.224.0.0/11"
    "220.96.0.0/11"
    "220.144.0.0/12"
    "220.160.0.0/11"
    "220.192.0.0/12"
    "220.224.0.0/11"
    "221.0.0.0/12"
    "221.112.0.0/12"
    "221.128.0.0/12"
    "221.160.0.0/11"
    "221.192.0.0/11"
    "221.224.0.0/12"
    "222.16.0.0/12"
    "222.32.0.0/11"
    "222.64.0.0/11"
    "222.112.0.0/12"
    "222.128.0.0/12"
    "222.160.0.0/11"
    "222.192.0.0/11"
    "222.240.0.0/12"
    "223.0.0.0/11"
    "223.64.0.0/10"
    "223.128.0.0/11"
    "223.160.0.0/12"
    "223.192.0.0/11"
    "223.240.0.0/12"
  ];

  v4.non-china-12 = [
    "1.96.0.0/12"
    "1.128.0.0/11"
    "1.160.0.0/12"
    "1.208.0.0/12"
    "1.224.0.0/11"
    "2.0.0.0/7"
    "4.0.0.0/6"
    "8.0.0.0/7"
    "11.0.0.0/8"
    "12.0.0.0/7"
    "14.32.0.0/11"
    "14.64.0.0/11"
    "14.160.0.0/11"
    "14.224.0.0/11"
    "15.0.0.0/8"
    "16.0.0.0/5"
    "24.0.0.0/7"
    "26.0.0.0/8"
    "27.64.0.0/11"
    "27.160.0.0/12"
    "27.240.0.0/12"
    "28.0.0.0/6"
    "32.0.0.0/6"
    "36.64.0.0/11"
    "36.224.0.0/12"
    "37.0.0.0/8"
    "38.0.0.0/8"
    "39.16.0.0/12"
    "39.32.0.0/11"
    "39.112.0.0/12"
    "39.192.0.0/10"
    "40.0.0.0/10"
    "40.80.0.0/12"
    "40.96.0.0/12"
    "40.128.0.0/9"
    "41.0.0.0/8"
    "42.16.0.0/12"
    "42.32.0.0/12"
    "42.64.0.0/12"
    "43.0.0.0/9"
    "43.192.0.0/11"
    "44.0.0.0/8"
    "45.0.0.0/11"
    "45.48.0.0/12"
    "45.80.0.0/12"
    "45.96.0.0/12"
    "45.128.0.0/10"
    "45.192.0.0/11"
    "45.224.0.0/12"
    "46.0.0.0/8"
    "47.0.0.0/10"
    "47.64.0.0/12"
    "47.128.0.0/9"
    "48.0.0.0/8"
    "49.16.0.0/12"
    "49.32.0.0/12"
    "49.96.0.0/12"
    "49.160.0.0/11"
    "49.192.0.0/12"
    "50.0.0.0/7"
    "52.0.0.0/10"
    "52.64.0.0/12"
    "52.96.0.0/11"
    "52.144.0.0/12"
    "52.160.0.0/11"
    "52.192.0.0/10"
    "53.0.0.0/8"
    "54.0.0.0/9"
    "54.128.0.0/10"
    "54.192.0.0/12"
    "54.224.0.0/11"
    "55.0.0.0/8"
    "56.0.0.0/7"
    "58.160.0.0/11"
    "58.224.0.0/12"
    "59.0.0.0/11"
    "59.112.0.0/12"
    "59.128.0.0/12"
    "60.32.0.0/12"
    "60.64.0.0/10"
    "60.128.0.0/11"
    "61.64.0.0/12"
    "61.96.0.0/11"
    "61.192.0.0/11"
    "62.0.0.0/9"
    "62.128.0.0/10"
    "62.192.0.0/11"
    "62.240.0.0/12"
    "63.0.0.0/8"
    "64.0.0.0/6"
    "68.0.0.0/10"
    "68.80.0.0/12"
    "68.96.0.0/11"
    "68.128.0.0/9"
    "69.0.0.0/9"
    "69.128.0.0/10"
    "69.192.0.0/11"
    "69.240.0.0/12"
    "70.0.0.0/8"
    "71.0.0.0/9"
    "71.144.0.0/12"
    "71.160.0.0/11"
    "71.192.0.0/10"
    "72.0.0.0/5"
    "80.0.0.0/8"
    "81.0.0.0/10"
    "81.80.0.0/12"
    "81.96.0.0/11"
    "81.128.0.0/9"
    "82.0.0.0/9"
    "82.128.0.0/12"
    "82.160.0.0/11"
    "82.192.0.0/10"
    "83.0.0.0/8"
    "84.0.0.0/6"
    "88.0.0.0/6"
    "92.0.0.0/7"
    "94.0.0.0/9"
    "94.128.0.0/11"
    "94.160.0.0/12"
    "94.192.0.0/10"
    "95.0.0.0/8"
    "96.0.0.0/6"
    "100.0.0.0/10"
    "100.128.0.0/9"
    "101.160.0.0/11"
    "101.208.0.0/12"
    "102.0.0.0/8"
    "103.176.0.0/12"
    "104.0.0.0/7"
    "106.128.0.0/10"
    "106.192.0.0/11"
    "106.240.0.0/12"
    "107.0.0.0/8"
    "108.0.0.0/8"
    "109.0.0.0/9"
    "109.128.0.0/10"
    "109.192.0.0/11"
    "109.224.0.0/12"
    "110.128.0.0/12"
    "111.96.0.0/12"
    "111.240.0.0/12"
    "112.144.0.0/12"
    "112.160.0.0/11"
    "112.208.0.0/12"
    "113.144.0.0/12"
    "113.160.0.0/11"
    "114.0.0.0/12"
    "114.32.0.0/12"
    "114.144.0.0/12"
    "114.160.0.0/11"
    "115.0.0.0/12"
    "115.128.0.0/12"
    "115.240.0.0/12"
    "116.32.0.0/12"
    "116.96.0.0/12"
    "117.192.0.0/10"
    "118.0.0.0/12"
    "118.32.0.0/11"
    "118.160.0.0/12"
    "119.192.0.0/11"
    "120.96.0.0/11"
    "120.144.0.0/12"
    "120.160.0.0/11"
    "121.112.0.0/12"
    "121.128.0.0/10"
    "121.208.0.0/12"
    "122.16.0.0/12"
    "122.32.0.0/12"
    "122.160.0.0/12"
    "122.208.0.0/12"
    "123.16.0.0/12"
    "123.32.0.0/12"
    "123.208.0.0/12"
    "124.48.0.0/12"
    "124.176.0.0/12"
    "125.0.0.0/12"
    "125.128.0.0/11"
    "125.176.0.0/12"
    "125.192.0.0/12"
    "125.224.0.0/12"
    "126.0.0.0/8"
    "128.0.0.0/10"
    "128.64.0.0/11"
    "128.112.0.0/12"
    "128.128.0.0/9"
    "129.0.0.0/12"
    "129.32.0.0/11"
    "129.64.0.0/10"
    "129.128.0.0/10"
    "129.224.0.0/11"
    "130.0.0.0/7"
    "132.0.0.0/9"
    "132.128.0.0/10"
    "132.192.0.0/11"
    "132.240.0.0/12"
    "133.0.0.0/8"
    "134.0.0.0/9"
    "134.128.0.0/11"
    "134.176.0.0/12"
    "134.192.0.0/10"
    "135.0.0.0/8"
    "136.0.0.0/8"
    "137.0.0.0/11"
    "137.32.0.0/12"
    "137.64.0.0/10"
    "137.128.0.0/9"
    "138.0.0.0/8"
    "139.16.0.0/12"
    "139.32.0.0/11"
    "139.64.0.0/10"
    "139.240.0.0/12"
    "140.0.0.0/10"
    "140.80.0.0/12"
    "140.96.0.0/11"
    "140.144.0.0/12"
    "140.160.0.0/12"
    "141.0.0.0/8"
    "142.0.0.0/10"
    "142.96.0.0/11"
    "142.128.0.0/9"
    "143.0.0.0/8"
    "144.16.0.0/12"
    "144.32.0.0/12"
    "144.64.0.0/11"
    "144.96.0.0/12"
    "144.128.0.0/10"
    "144.192.0.0/11"
    "144.224.0.0/12"
    "145.0.0.0/8"
    "146.0.0.0/11"
    "146.32.0.0/12"
    "146.64.0.0/10"
    "146.128.0.0/10"
    "146.208.0.0/12"
    "146.224.0.0/11"
    "147.0.0.0/8"
    "148.0.0.0/10"
    "148.80.0.0/12"
    "148.96.0.0/11"
    "148.128.0.0/9"
    "149.0.0.0/11"
    "149.48.0.0/12"
    "149.64.0.0/10"
    "149.128.0.0/9"
    "150.16.0.0/12"
    "150.32.0.0/11"
    "150.64.0.0/11"
    "150.96.0.0/12"
    "150.160.0.0/11"
    "150.192.0.0/12"
    "150.224.0.0/12"
    "151.0.0.0/8"
    "152.0.0.0/10"
    "152.64.0.0/11"
    "152.112.0.0/12"
    "152.144.0.0/12"
    "152.160.0.0/11"
    "152.192.0.0/10"
    "153.16.0.0/12"
    "153.48.0.0/12"
    "153.64.0.0/11"
    "153.128.0.0/9"
    "154.16.0.0/12"
    "154.32.0.0/11"
    "154.64.0.0/10"
    "154.128.0.0/9"
    "155.0.0.0/8"
    "156.0.0.0/8"
    "157.32.0.0/12"
    "157.64.0.0/11"
    "157.96.0.0/12"
    "157.128.0.0/12"
    "157.160.0.0/11"
    "157.192.0.0/11"
    "157.224.0.0/12"
    "158.0.0.0/11"
    "158.32.0.0/12"
    "158.80.0.0/12"
    "158.96.0.0/11"
    "158.128.0.0/9"
    "159.0.0.0/12"
    "159.32.0.0/11"
    "159.80.0.0/12"
    "159.96.0.0/11"
    "159.128.0.0/10"
    "159.192.0.0/11"
    "159.240.0.0/12"
    "160.0.0.0/12"
    "160.32.0.0/11"
    "160.64.0.0/10"
    "160.128.0.0/10"
    "160.208.0.0/12"
    "160.240.0.0/12"
    "161.0.0.0/10"
    "161.64.0.0/11"
    "161.96.0.0/12"
    "161.128.0.0/11"
    "161.160.0.0/12"
    "161.208.0.0/12"
    "161.224.0.0/11"
    "162.16.0.0/12"
    "162.32.0.0/11"
    "162.64.0.0/11"
    "162.112.0.0/12"
    "162.128.0.0/9"
    "163.16.0.0/12"
    "163.64.0.0/11"
    "163.96.0.0/12"
    "163.144.0.0/12"
    "163.160.0.0/12"
    "163.208.0.0/12"
    "163.240.0.0/12"
    "164.0.0.0/11"
    "164.32.0.0/12"
    "164.64.0.0/10"
    "164.128.0.0/9"
    "165.0.0.0/8"
    "166.0.0.0/10"
    "166.64.0.0/11"
    "166.112.0.0/12"
    "166.128.0.0/9"
    "167.0.0.0/9"
    "167.144.0.0/12"
    "167.160.0.0/12"
    "167.192.0.0/12"
    "167.224.0.0/11"
    "168.0.0.0/9"
    "168.128.0.0/11"
    "168.176.0.0/12"
    "168.192.0.0/10"
    "169.0.0.0/9"
    "169.128.0.0/10"
    "169.192.0.0/11"
    "169.224.0.0/12"
    "169.240.0.0/13"
    "169.248.0.0/14"
    "169.252.0.0/15"
    "169.255.0.0/16"
    "170.0.0.0/9"
    "170.128.0.0/11"
    "170.160.0.0/12"
    "170.192.0.0/10"
    "171.16.0.0/12"
    "171.48.0.0/12"
    "171.64.0.0/12"
    "171.128.0.0/10"
    "171.192.0.0/12"
    "171.224.0.0/11"
    "172.0.0.0/12"
    "172.32.0.0/11"
    "172.64.0.0/12"
    "172.96.0.0/11"
    "172.128.0.0/9"
    "173.0.0.0/8"
    "174.0.0.0/8"
    "175.112.0.0/12"
    "175.128.0.0/12"
    "175.192.0.0/10"
    "176.0.0.0/6"
    "180.0.0.0/10"
    "180.240.0.0/12"
    "181.0.0.0/8"
    "182.0.0.0/12"
    "182.64.0.0/12"
    "182.176.0.0/12"
    "182.208.0.0/12"
    "183.96.0.0/11"
    "184.0.0.0/8"
    "185.0.0.0/9"
    "185.128.0.0/10"
    "185.208.0.0/12"
    "185.224.0.0/11"
    "186.0.0.0/7"
    "188.0.0.0/9"
    "188.144.0.0/12"
    "188.160.0.0/11"
    "188.192.0.0/10"
    "189.0.0.0/8"
    "190.0.0.0/7"
    "192.0.0.8/29"
    "192.0.0.16/28"
    "192.0.0.32/27"
    "192.0.0.64/26"
    "192.0.0.128/25"
    "192.0.1.0/24"
    "192.0.3.0/24"
    "192.0.4.0/22"
    "192.0.8.0/21"
    "192.0.16.0/20"
    "192.0.32.0/19"
    "192.0.64.0/18"
    "192.0.128.0/17"
    "192.1.0.0/16"
    "192.2.0.0/15"
    "192.4.0.0/14"
    "192.8.0.0/13"
    "192.16.0.0/12"
    "192.32.0.0/12"
    "192.64.0.0/12"
    "192.80.0.0/13"
    "192.88.0.0/18"
    "192.88.64.0/19"
    "192.88.96.0/23"
    "192.88.98.0/24"
    "192.88.100.0/22"
    "192.88.104.0/21"
    "192.88.112.0/20"
    "192.88.128.0/17"
    "192.89.0.0/16"
    "192.90.0.0/15"
    "192.92.0.0/14"
    "192.160.0.0/13"
    "192.169.0.0/16"
    "192.170.0.0/15"
    "192.172.0.0/14"
    "192.176.0.0/12"
    "192.208.0.0/12"
    "192.224.0.0/11"
    "193.0.0.0/10"
    "193.64.0.0/11"
    "193.96.0.0/12"
    "193.128.0.0/9"
    "194.0.0.0/7"
    "196.0.0.0/7"
    "198.0.0.0/12"
    "198.16.0.0/15"
    "198.20.0.0/14"
    "198.24.0.0/13"
    "198.32.0.0/12"
    "198.48.0.0/15"
    "198.50.0.0/16"
    "198.51.0.0/18"
    "198.51.64.0/19"
    "198.51.96.0/22"
    "198.51.101.0/24"
    "198.51.102.0/23"
    "198.51.104.0/21"
    "198.51.112.0/20"
    "198.51.128.0/17"
    "198.52.0.0/14"
    "198.56.0.0/13"
    "198.64.0.0/10"
    "198.128.0.0/11"
    "198.176.0.0/12"
    "198.192.0.0/10"
    "199.0.0.0/9"
    "199.128.0.0/10"
    "199.192.0.0/12"
    "199.224.0.0/11"
    "200.0.0.0/7"
    "202.208.0.0/12"
    "202.224.0.0/11"
    "203.224.0.0/11"
    "204.0.0.0/11"
    "204.32.0.0/12"
    "204.64.0.0/10"
    "204.128.0.0/9"
    "205.0.0.0/8"
    "206.0.0.0/7"
    "208.0.0.0/7"
    "210.96.0.0/11"
    "210.128.0.0/11"
    "210.160.0.0/12"
    "210.208.0.0/12"
    "210.224.0.0/11"
    "211.0.0.0/10"
    "211.112.0.0/12"
    "211.176.0.0/12"
    "211.192.0.0/10"
    "212.0.0.0/10"
    "212.80.0.0/12"
    "212.96.0.0/11"
    "212.144.0.0/12"
    "212.160.0.0/11"
    "212.192.0.0/10"
    "213.0.0.0/8"
    "214.0.0.0/7"
    "216.0.0.0/7"
    "218.32.0.0/12"
    "218.112.0.0/12"
    "218.128.0.0/11"
    "218.160.0.0/12"
    "218.208.0.0/12"
    "218.224.0.0/12"
    "219.0.0.0/10"
    "219.96.0.0/11"
    "219.160.0.0/11"
    "219.192.0.0/12"
    "220.0.0.0/10"
    "220.64.0.0/11"
    "220.128.0.0/12"
    "220.208.0.0/12"
    "221.16.0.0/12"
    "221.32.0.0/11"
    "221.64.0.0/11"
    "221.96.0.0/12"
    "221.144.0.0/12"
    "221.240.0.0/12"
    "222.0.0.0/12"
    "222.96.0.0/12"
    "222.144.0.0/12"
    "222.224.0.0/12"
    "223.32.0.0/11"
    "223.176.0.0/12"
    "223.224.0.0/12"
  ];
}
