# GKE Gateway API Scalability 

This repository is used to benchmark Gateway API on Google Kubernetes Engine, to surface potential limits & quotas.

## Findings

While GKE itself doesn't run in any particular limits, since Gateway API provisions a L7XLB (or other type of loadbalancer) in Google Cloud, this has some pretty tight limit for some applications.

Especially if you want to have very high number of s

## How to reproduce

First, edit variables.tf with your custom settings

Spin up the infrastructure: 

`tf apply`

Generate 100 customers 

`./generate-customers.sh`

Deploy the manifests

`kubectl apply -f k8s/`

Wait for the cluster to reconcile and after run:

`./test-endpoints.sh`
