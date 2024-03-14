#!/bin/bash

# check swap usage until exiting the script and replace the current value instead of a new line

while true; do
	echo "Swap Usage: $(free -m | awk '/Swap/ {print $3}') MB"
	sleep 1
done
