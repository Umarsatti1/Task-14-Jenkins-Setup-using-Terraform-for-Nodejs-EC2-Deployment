#!/bin/bash
set -e

echo "Waiting for internet..."
until ping -c 1 google.com >/dev/null 2>&1; do sleep 2; done

# Java OpenJDK installation
apt update -y
apt install -y fontconfig openjdk-21-jre curl

# Jenkins installation
mkdir -p /etc/apt/keyrings

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  -o /etc/apt/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

apt update -y
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins