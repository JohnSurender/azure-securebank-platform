variable "name" {
  description = "Key Vault name (3-24 chars, globally unique)"
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
variable "pe_subnet_id" {
  description = "Private endpoint subnet ID"
  type        = string
}
variable "private_dns_zone_id" {
  description = "privatelink.vaultcore.azure.net zone ID"
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
