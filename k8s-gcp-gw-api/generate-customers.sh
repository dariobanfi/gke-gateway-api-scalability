#!/bin/bash

mkdir -p manifests/customers

for i in {1..100}; do
    # Create the customer name
    customer="customer$i"
    
    # Create the output file path
    output_file="manifests/customers/${customer}.yaml"
    
    # Use sed to replace %CUSTOMER% with the customer name and save to output file
    sed "s/%CUSTOMER%/${customer}/g" pod-template.yaml.tpl > "$output_file"
    
    echo "Generated manifest for ${customer}"
done 