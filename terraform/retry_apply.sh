#!/bin/bash
while true; do
  terraform apply -auto-approve && break
  echo "$(date): Out of capacity, retrying in 120s..."
  sleep 120
done
