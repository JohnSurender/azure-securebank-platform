output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}
output "oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
output "workload_identity_client_id" {
  description = "Client ID to annotate Kubernetes service accounts with"
  value       = azurerm_user_assigned_identity.workload.client_id
}
