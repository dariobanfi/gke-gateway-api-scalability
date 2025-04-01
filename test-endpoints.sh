#!/bin/bash

# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to call the endpoint and display the HTTP status code with color
call_endpoint() {
  local url="$1"
  http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

  if [[ "$http_code" -eq 200 ]]; then
    echo -e "${GREEN}$url - HTTP Status Code: $http_code${NC}"
  else
    echo -e "${RED}$url - HTTP Status Code: $http_code${NC}"
  fi
}

# Loop through numbers 1 to 100 and call the endpoint in parallel
for i in $(seq 1 500); do
  url="https://customer${i}.lbimits.dariobanfi.demo.altostrat.com/"
  call_endpoint "$url" & # The '&' at the end runs the command in the background (parallel)
done

# Wait for all background processes to finish
wait