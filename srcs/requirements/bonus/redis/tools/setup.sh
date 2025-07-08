#!/bin/bash

echo "Updating Redis configuration to allow connections from any IP..."
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf 

echo "Updating Redis configuration with memory limits and policy..."
cat << lim > /etc/redis/redis.conf
maxmemory 256mb
maxmemory-policy allkeys-lfu 
lim 

echo "Redis configuration updated successfully with maxmemory and allkeys-lfu policy."
