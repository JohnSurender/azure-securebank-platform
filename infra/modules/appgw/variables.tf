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
variable "subnet_id" {
  description = "Dedicated App Gateway subnet"
  type        = string
}
variable "waf_mode" {
  description = "Detection (dev) or Prevention (staging/prod)"
  type        = string
  default     = "Prevention"
}
variable "min_capacity" {
  description = "Autoscale min instances"
  type        = number
  default     = 1
}
variable "max_capacity" {
  description = "Autoscale max instances"
  type        = number
  default     = 3
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
