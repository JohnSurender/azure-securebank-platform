output "fqdn" {
  description = "Server FQDN (private)"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}
output "id" {
  description = "Server ID"
  value       = azurerm_postgresql_flexible_server.this.id
}
