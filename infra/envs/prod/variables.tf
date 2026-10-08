variable "environment" {
  description = "dev | staging | prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}
variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}
variable "location_short" {
  description = "Short region code used in names"
  type        = string
  default     = "uks"
}
variable "hub_cidr" {
  description = "Hub VNet CIDR"
  type        = string
}
variable "spoke_cidr" {
  description = "Spoke VNet CIDR"
  type        = string
}
variable "alert_email" {
  description = "Alert / budget email"
  type        = string
}
variable "log_retention_days" {
  description = "Log Analytics retention"
  type        = number
}
variable "postgres_sku" {
  description = "PostgreSQL SKU"
  type        = string
}
variable "postgres_backup_days" {
  description = "PostgreSQL backup retention"
  type        = number
}
variable "postgres_geo_backup" {
  description = "Geo-redundant backup"
  type        = bool
}
variable "postgres_ha" {
  description = "Zone-redundant HA"
  type        = bool
}
variable "waf_mode" {
  description = "WAF mode"
  type        = string
}
variable "appgw_min_capacity" {
  description = "App Gateway min instances"
  type        = number
}
variable "appgw_max_capacity" {
  description = "App Gateway max instances"
  type        = number
}
variable "aks_sku_tier" {
  description = "AKS tier"
  type        = string
}
variable "aks_admin_group_ids" {
  description = "Entra ID admin groups"
  type        = list(string)
  default     = []
}
variable "aks_api_authorized_ip_ranges" {
  description = "API server allow-list"
  type        = list(string)
  default     = []
}
variable "aks_apps_vm_size" {
  description = "Apps pool VM size"
  type        = string
}
variable "aks_apps_min" {
  description = "Apps pool min"
  type        = number
}
variable "aks_apps_max" {
  description = "Apps pool max"
  type        = number
}
variable "aks_system_min" {
  description = "System pool min"
  type        = number
}
variable "monthly_budget_gbp" {
  description = "Monthly budget for the RG"
  type        = number
}
variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}
