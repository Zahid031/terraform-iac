#!/bin/bash
set -e

# ── System update ────────────────────────
apt-get update -y
apt-get upgrade -y

# ── Install Nginx ────────────────────────
apt-get install -y nginx

# ── Start & enable on boot ───────────────
systemctl start nginx
systemctl enable nginx

# ── Custom index page ────────────────────
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html>
  <head><title>${instance_name}</title></head>
  <body>
    <h1>Hello from ${instance_name}!</h1>
    <p>Environment : ${environment}</p>
    <p>Project     : ${project}</p>
  </body>
</html>
HTML