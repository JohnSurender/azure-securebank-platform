resource "azurerm_container_registry" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Premium" # required for Private Link, geo-replication, content trust
  admin_enabled                 = false
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = true
  tags                          = var.tags

  retention_policy_in_days = 30
  trust_policy_enabled     = true
}

resource "azurerm_private_endpoint" "acr" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category_group = "audit" }
  enabled_metric { category = "AllMetrics" }
}
