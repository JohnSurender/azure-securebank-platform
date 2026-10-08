output "resource_group" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}
output "aks_cluster_name" {
  description = "AKS cluster"
  value       = module.aks.cluster_name
}
output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr.login_server
}
output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.keyvault.vault_uri
}
output "app_gateway_public_ip" {
  description = "Public entry point"
  value       = module.appgw.public_ip
}
output "workload_identity_client_id" {
  description = "Annotate service accounts with this client ID"
  value       = module.aks.workload_identity_client_id
}
output "postgres_fqdn" {
  description = "Private PostgreSQL FQDN"
  value       = module.postgres.fqdn
}
