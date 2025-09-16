#!/bin/bash
# Build and install Squid 6.12 from source

sudo dnf groupinstall "Development Tools" -y
sudo dnf install gcc gcc-c++ make openssl-devel pam-devel libcap-devel libuuid-devel libdb-devel wget tar -y

wget http://www.squid-cache.org/Versions/v6/squid-6.12.tar.gz
tar -xvzf squid-6.12.tar.gz
cd squid-6.12

./configure --prefix=/usr --sysconfdir=/etc/squid --with-openssl --enable-ssl --enable-ssl-crtd
make -j$(nproc)
sudo make install

sudo squid -z
sudo systemctl enable --now squid
