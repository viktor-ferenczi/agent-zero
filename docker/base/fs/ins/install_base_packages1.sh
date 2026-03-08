#!/bin/bash
set -e

echo "====================BASE PACKAGES1 START===================="

apt-get update && apt-get upgrade -y

apt-get install -y --no-install-recommends \
    sudo curl wget git cron \
    zip unzip p7zip-full bzip2 xz-utils zstd \
    tar gzip file less jq tree htop procps \
    net-tools iputils-ping dnsutils iproute2 \
    ca-certificates gnupg lsb-release

echo "====================BASE PACKAGES1 DOTNET===================="

# Add Microsoft package repository and install .NET 10
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb
apt-get update
apt-get install -y --no-install-recommends dotnet-sdk-10.0

echo "====================BASE PACKAGES1 END===================="
