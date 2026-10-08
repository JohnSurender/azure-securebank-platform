variable "name" {
  description = "Globally unique ACR name (alphanumeric)"
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
  description = "privatelink.azurecr.io zone ID"
  type        = string
}
variable "log_analytics_workspace_id" {
  description = "Diagnostics destination"
  type        = string
}
variable "public_network_access_enabled" {
  description = "Allow public pushes (CI). Set false once self-hosted runners are in the VNet."
  type        = bool
  default     = true
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
