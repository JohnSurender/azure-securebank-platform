resource "random_password" "admin" {
  length           = 32
  special          = true
  override_special = "!#%*-_=+"
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  version                       = "16"
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false
  administrator_login           = "pgadmin"
  administrator_password        = random_password.admin.result
  zone                          = "1"
  tags                          = var.tags

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
  }

  dynamic "high_availability" {
    for_each = var.high_availability ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }

  lifecycle {
    ignore_changes = [zone, high_availability[0].standby_availability_zone]
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "require_tls" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_database" "bank" {
  name      = "securebank"
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Store admin password in Key Vault - never output it
resource "azurerm_key_vault_secret" "pg_admin" {
  name         = "pg-admin-password"
  value        = random_password.admin.result
  key_vault_id = var.key_vault_id
  content_type = "password"
}

resource "azurerm_monitor_diagnostic_setting" "pg" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category_group = "audit" }
  enabled_metric { category = "AllMetrics" }
}
