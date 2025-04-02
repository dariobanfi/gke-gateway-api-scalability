# GKE Gateway API Scalability 

This repository is used to benchmark Gateway API on Google Kubernetes Engine, to surface potential limits & quotas.
This is used to test large cluster (10k+ services) where each service is exposed through the internet under a subdomain, e.g. customer1.domain.com. Mostly thought for SaaS platforms for server hosting.

## Findings

While GKE itself doesn't run in any particular limits, since Gateway API provisions a [Global External Application Load Balancer](https://cloud.google.com/load-balancing/docs/https) (L7XLB) in Google Cloud. L7XLB has some pretty tight limit for some applications.


Especially if you want to have very high number of publicly exposed service, because of [Container Native Load Balancing](https://cloud.google.com/kubernetes-engine/docs/concepts/container-native-load-balancing), there will be the following created:

- global_external_managed_backend_services
- health_checks
- network_endpoint_groups

While these resources have quotas and can easily increased above 10k, going a lot more beyond that limit is going to create some issues.

But more importantly, the issue is the limit of URL Map. According to the [Google Cloud Load Balancing quotas documentation](https://cloud.google.com/load-balancing/quotas#url_maps), there is a default limit of 100 URL maps per project, which can be increased up to 1000 through quota requests.
The size, as of now, is 64KB, which roughly supports only little more than 100 HttpRoutes (in this specific example). We're working on extending that significantly, but because of that, using one single Gateway right now may not the best choice for large clusters with a lot of exposed services.

## What are my options?

I can think of few options:

### Multiple Gateway objects

You create multiple Gateways and you associate a maximum of 100 Httproutes per Gateway

**Pros**: You keep using Gateway API fully using k8s YAMLs. You still can use container-native load balancing. LB takes care of TLS termination, scaling with traffic, global routing, WAF, CDN, etc.

**Contra**: You need a DNS logic to shard domains to different LB IPs, and some logic to assign different routes to different Gateways

### Using k8s Ingress Gateway and point Load Balancer to it using Standalone NEG

With this approach, the entry point for your traffic is still the L7XLB, but this is the routed to the cluster ingress through the Standalone NEG, and from there routing to the deployment happens based on hostname.


**Pros**: You keep using still use LB  which takes care of TLS termination, scaling with traffic, global routing, WAF, CDN, etc. You have more flexibility with the custom ingress controller

**Contra**: You lose container-native load balancing. You need to manage and scale you ingress controller. You pay for LB traffic and for the ingress running in your cluster.

### Using k8s Ingress Gateway exposed directly to internet with a l4 Passthrough Load Balancer

**Pros**: No limitations, depending on the ingress your choose.

**Contra**: You lose container-native load balancing. You need to manage and scale you ingress controller. You lose all the goodies of L7XLB.

## How to run yourself

First, edit variables.tf with your custom settings

Spin up the infrastructure: 

`tf apply`

Generate 100 customers 

`./generate-customers.sh`

Deploy the manifests

`kubectl apply -f manifests/`

Wait for the cluster to reconcile and after run:

`./test-endpoints.sh`
