#!/bin/bash
set -e

echo "Waiting for internet..."
until ping -c 1 google.com >/dev/null 2>&1; do sleep 2; done

apt update -y
apt install -y curl git nginx unzip

# Install Node.js (system-wide)
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt install -y nodejs

node -v
npm -v

# Install PM2
npm install -g pm2

pm2 startup systemd -u ubuntu --hp /home/ubuntu

# App directories
mkdir -p /var/www/nodeapp_new /var/www/nodeapp_current /var/www/nodeapp_previous
chown -R ubuntu:ubuntu /var/www

# Nginx reverse proxy
cat <<EOF >/etc/nginx/sites-available/nodeapp
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
    }
}
EOF

ln -sf /etc/nginx/sites-available/nodeapp /etc/nginx/sites-enabled/nodeapp
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx

# CloudWatch Agent
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E amazon-cloudwatch-agent.deb

cat <<EOF >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "amazon-cloudwatch-agent.log"
          },
          {
            "file_path": "/home/ubuntu/.pm2/logs/*.log",
            "log_group_name": "/nodeapp/pm2",
            "log_stream_name": "{instance_id}-pm2"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/nodeapp/nginx-access-logs",
            "log_stream_name": "{instance_id}-access"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/nodeapp/nginx-error-logs",
            "log_stream_name": "{instance_id}-error"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
