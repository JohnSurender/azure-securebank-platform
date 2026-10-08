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
variable "kubernetes_version" {
  description = "AKS version (null = latest default)"
  type        = string
  default     = null
}
variable "sku_tier" {
  description = "Free (dev) or Standard (uptime SLA)"
  type        = string
  default     = "Free"
}
variable "aks_subnet_id" {
  description = "Node subnet ID"
  type        = string
}
variable "appgw_subnet_id" {
  description = "App Gateway subnet ID (for AGIC role)"
  type        = string
}
variable "application_gateway_id" {
  description = "App Gateway ID used by AGIC"
  type        = string
}
variable "acr_id" {
  description = "ACR ID for AcrPull"
  type        = string
}
variable "key_vault_id" {
  description = "Key Vault ID for workload identity"
  type        = string
}
variable "log_analytics_workspace_id" {
  description = "Container Insights / Defender workspace"
  type        = string
}
variable "admin_group_object_ids" {
  description = "Entra ID groups with cluster-admin"
  type        = list(string)
  default     = []
}
variable "api_authorized_ip_ranges" {
  description = "CIDRs allowed to reach the API server"
  type        = list(string)
  default     = []
}
variable "system_vm_size" {
  description = "System pool VM size"
  type        = string
  default     = "Standard_D2s_v5"
}
variable "system_min_count" {
  description = "System pool min nodes"
  type        = number
  default     = 1
}
variable "system_max_count" {
  description = "System pool max nodes"
  type        = number
  default     = 3
}
variable "apps_vm_size" {
  description = "Apps pool VM size"
  type        = string
  default     = "Standard_D4s_v5"
}
variable "apps_min_count" {
  description = "Apps pool min nodes"
  type        = number
  default     = 1
}
variable "apps_max_count" {
  description = "Apps pool max nodes"
  type        = number
  default     = 5
}
variable "workload_service_accounts" {
  description = "Kubernetes service accounts federated to the workload identity"
  type        = list(string)
  default     = ["accounts-service", "transactions-service"]
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
