output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.hub.id
}
output "spoke_vnet_id" {
  description = "Spoke VNet ID"
  value       = azurerm_virtual_network.spoke.id
}
output "appgw_subnet_id" {
  description = "Application Gateway subnet"
  value       = azurerm_subnet.appgw.id
}
output "aks_subnet_id" {
  description = "AKS node subnet"
  value       = azurerm_subnet.aks.id
}
output "pe_subnet_id" {
  description = "Private endpoint subnet"
  value       = azurerm_subnet.private_endpoints.id
}
output "postgres_subnet_id" {
  description = "Delegated PostgreSQL subnet"
  value       = azurerm_subnet.postgres.id
}
output "private_dns_zone_ids" {
  description = "Map of private DNS zone IDs"
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}
