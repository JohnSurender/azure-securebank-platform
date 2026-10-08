variable "name" {
  description = "PostgreSQL server name"
  type        = string
}
variable "location" {
  description = "Azure region"
  type        = string
}
variable "resource_group_name" {
  description = "Target resource group"
  type        = string
}
variable "sku_name" {
  description = "Compute SKU, e.g. B_Standard_B1ms (dev) or GP_Standard_D4ds_v5 (prod)"
  type        = string
}
variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}
variable "backup_retention_days" {
  description = "Point-in-time restore window"
  type        = number
  default     = 7
}
variable "geo_redundant_backup" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}
variable "high_availability" {
  description = "Enable zone-redundant HA"
  type        = bool
  default     = false
}
variable "delegated_subnet_id" {
  description = "Delegated subnet for VNet integration"
  type        = string
}
variable "private_dns_zone_id" {
  description = "privatelink.postgres.database.azure.com zone ID"
  type        = string
}
variable "key_vault_id" {
  description = "Key Vault to store admin password"
  type        = string
}
variable "log_analytics_workspace_id" {
  description = "Diagnostics destination"
  type        = string
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
