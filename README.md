# Squid Proxy 6.12 on Red Hat / CentOS Stream 9

## 🚨 Why this repo?
By default, CentOS Stream 9 / RHEL 9 provides **Squid v5.5** in its repos.  
That version has **known vulnerabilities** and should not be used in production.  

The stable and secure release is **Squid v6.12**, but it is **not available in yum/dnf repos**.  
Instead, it must be **built manually from source**.  

This repository provides a **tested step-by-step guide** (based on real-world experience) to install and configure Squid 6.12 as a **forward proxy server** on Red Hat–based systems.

---

## 📌 Option 1: Default Repo (Not Recommended – Vulnerable)

```bash
# Check what version is available in the repo
dnf info squid

# Install (will install 5.5, which has vulnerabilities)
sudo dnf install squid -y

# Enable and start Squid
sudo systemctl enable --now squid

# Verify version (should show 5.5)
squid --version
