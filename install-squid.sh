#!/bin/bash
# Squid 6.12 install from source for RHEL / CentOS Stream

set -e

SQUID_VER=6.12
SQUID_USER=squid
SQUID_GROUP=squid
PREFIX=/usr
SYSCONFDIR=/etc/squid

echo "==> Installing build dependencies..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y gcc gcc-c++ make \
    openssl-devel pam-devel libcap-devel libuuid-devel libdb-devel \
    wget tar

echo "==> Creating squid user/group..."
if ! id -u $SQUID_USER >/dev/null 2>&1; then
    sudo groupadd -r $SQUID_GROUP
    sudo useradd -r -g $SQUID_GROUP -s /sbin/nologin -d /var/spool/squid $SQUID_USER
fi

echo "==> Downloading Squid $SQUID_VER..."
wget http://www.squid-cache.org/Versions/v6/squid-$SQUID_VER.tar.gz
tar -xvzf squid-$SQUID_VER.tar.gz
cd squid-$SQUID_VER

echo "==> Configuring..."
./configure --prefix=$PREFIX --sysconfdir=$SYSCONFDIR \
    --with-openssl --enable-ssl --enable-ssl-crtd

echo "==> Building..."
make -j$(nproc)

echo "==> Installing..."
sudo make install

echo "==> Creating directories..."
sudo mkdir -p /var/log/squid /var/spool/squid
sudo chown -R $SQUID_USER:$SQUID_GROUP /var/log/squid /var/spool/squid

echo "==> Writing systemd service file..."
sudo tee /etc/systemd/system/squid.service > /dev/null <<EOF
[Unit]
Description=Squid caching proxy
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/squid -sYC
ExecReload=/usr/sbin/squid -k reconfigure
ExecStop=/usr/sbin/squid -k shutdown
PIDFile=/var/run/squid.pid
User=$SQUID_USER
Group=$SQUID_GROUP

[Install]
WantedBy=multi-user.target
EOF

echo "==> Reloading systemd..."
sudo systemctl daemon-reexec

echo "==> Initializing cache..."
sudo squid -z

echo "==> Enabling and starting Squid..."
sudo systemctl enable --now squid

echo "==> Done!"
squid -v
systemctl status squid --no-pager
