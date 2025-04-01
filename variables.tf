variable "project_id" {
  type        = string
  default     = "darioenv-lb-limits"
}

variable "region" {
  type        = string
  default     = "europe-west4"
}

variable "cluster_name" {
  type        = string
  default     = "autopilot-limits-demo"
}

variable "network_name" {
  type        = string
  default     = "default"
}

variable "wildcard_domain" {
  type        = string
  default     = "*.lbimits.dariobanfi.demo.altostrat.com"
}

variable "base_domain_for_auth" {
  type        = string
  default     = "lbimits.dariobanfi.demo.altostrat.com"
}

variable "cert_base_name" {
  type        = string
  default     = "lbimits-wildcard" # Used to derive resource names
}
