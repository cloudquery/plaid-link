#!/bin/sh

# Set certificate and key file paths
CERT_FILE="/etc/nginx/ssl/nginx.crt"
KEY_FILE="/etc/nginx/ssl/nginx.key"

# Check if certificate and key files exist
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  echo "Certificates not found, generating self-signed certificates..."
  mkdir -p /etc/nginx/ssl
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CERT_FILE" -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost" > /dev/null 2>&1
  echo "Self-signed certificates generated."
else
  echo "Using existing certificates."
fi

echo You can use your own certificates by mounting them to /etc/nginx/ssl/nginx.crt and /etc/nginx/ssl/nginx.key

echo "Starting Plaid Link api server"
/app/api > /dev/null &
p1=$!

echo "Starting Plaid Link frontend server"
nginx -g "daemon off;" > /dev/null &
p2=$!

echo "Services started, visit https://localhost to use Plaid Link."
echo "Press Ctrl+C to stop the services."
wait $p1 $p2
