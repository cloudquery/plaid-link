#!/bin/sh

ls -alh /app

echo "Starting Plaid Link api server"
/app/api &
p1=$!

echo "Starting Plaid Link frontend server"
nginx -g "daemon off;" &
p2=$!

echo "Services started, visit http://localhost:3000 to use Plaid Link."
echo "Press Ctrl+C to stop the services."
wait $p1 $p2
