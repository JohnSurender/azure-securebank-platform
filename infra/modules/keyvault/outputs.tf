output "id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.this.id
}
output "vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.this.vault_uri
}
