#!/bin/bash

# Create the customers directory if it doesn't exist
mkdir -p k8s/customers

# Loop from 1 to 100
for i in {1..100}; do
    # Create the customer name
    customer="customer$i"
    
    # Create the output file path
    output_file="k8s/customers/${customer}.yaml"
    
    # Use sed to replace %CUSTOMER% with the customer name and save to output file
    sed "s/%CUSTOMER%/${customer}/g" pod-template.yaml > "$output_file"
    
    echo "Generated manifest for ${customer}"
done 