#!/bin/bash
DEVICE="/dev/nvme1n1"
MOUNT_POINT="/var/lib/jenkins"

while [ ! -b $DEVICE ]; do sleep 5; done

mkdir -p $MOUNT_POINT
if ! blkid $DEVICE | grep -q ext4; then
  mkfs.ext4 $DEVICE
fi
mount $DEVICE $MOUNT_POINT
if ! grep -q "$MOUNT_POINT" /etc/fstab; then
  echo "$DEVICE $MOUNT_POINT ext4 defaults 0 2" >> /etc/fstab
fi

apt-get update -y
apt-get install -y fontconfig openjdk-21-jre-headless

mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" \
  > /etc/apt/sources.list.d/jenkins.list

apt-get update -y
apt-get install -y jenkins

chown -R jenkins:jenkins $MOUNT_POINT

systemctl enable jenkins
systemctl start jenkins