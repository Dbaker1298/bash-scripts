#!/usr/bin/env bash

# Simple script to find availble ips on my private network

for ip in {1..254}; do
	ping -c 1 192.168.1.$ip | grep "64 bytes" | cut -d " " -f 4 | cut -d ":" -f 1 &
done
