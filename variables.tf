variable "project_id" {
  type        = string
  default     = "darioenv-lb-limits"
}

# I centralize my DNS records in one separate project, but you can use the same as project_id
variable "dns_project_id" {
  type        = string
  default     = "darioenv-clouddns"
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
  description = "Base name for Certificate Manager resources."
  type        = string
  default     = "lbimits-wildcard"
}

variable "dns_zone_name" {
  description = "Name for the DNS zone"
  type        = string
  default     = "dariobanfi-demo"
}