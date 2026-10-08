output "id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.this.id
}
output "public_ip" {
  description = "Public IP of the gateway"
  value       = azurerm_public_ip.appgw.ip_address
}
