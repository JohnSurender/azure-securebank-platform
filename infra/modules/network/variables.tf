variable "name_suffix" {
  description = "Naming suffix, e.g. securebank-dev-uks"
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
variable "hub_cidr" {
  description = "Hub VNet CIDR (/16 recommended)"
  type        = string
}
variable "spoke_cidr" {
  description = "Spoke VNet CIDR (/16 recommended)"
  type        = string
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
