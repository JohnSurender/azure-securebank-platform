variable "name_suffix" {
  description = "Naming suffix"
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
variable "retention_days" {
  description = "Log retention (PCI DSS 10.5.1 requires 12 months total, 3 months immediately available)"
  type        = number
  default     = 90
}
variable "alert_email" {
  description = "On-call email for alerts"
  type        = string
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
