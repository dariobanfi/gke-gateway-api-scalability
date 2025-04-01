variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
  # Replace with your actual project ID or set via TF_VAR_project_id environment variable
  default     = "darioenv-lb-limits"
}

variable "region" {
  description = "The Google Cloud region for the GKE cluster."
  type        = string
  default     = "europe-west4"
}

variable "cluster_name" {
  description = "The name for the GKE Autopilot cluster."
  type        = string
  default     = "autopilot-limits-demo"
}

variable "network_name" {
  description = "The name of the VPC network to use."
  type        = string
  default     = "default"
}

variable "wildcard_domain" {
  description = "The wildcard domain name for the certificate."
  type        = string
  default     = "*.lbimits.dariobanfi.demo.altostrat.com"
}

variable "base_domain_for_auth" {
  description = "The base domain used for DNS authorization (without the wildcard)."
  type        = string
  default     = "lbimits.dariobanfi.demo.altostrat.com"
}

variable "cert_base_name" {
  description = "Base name for Certificate Manager resources."
  type        = string
  default     = "lbimits-wildcard" # Used to derive resource names
}
