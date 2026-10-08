locals {
  name_suffix = "securebank-${var.environment}-${var.location_short}"
  # Globally-unique names cannot contain hyphens
  compact = "securebank${var.environment}${var.location_short}"
  tags = merge(var.tags, {
    environment = var.environment
    project     = "securebank"
    managed_by  = "terraform"
    data_class  = "confidential"
  })
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  name_suffix         = local.name_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  retention_days      = var.log_retention_days
  alert_email         = var.alert_email
  tags                = local.tags
}

module "network" {
  source              = "../../modules/network"
  name_suffix         = local.name_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  hub_cidr            = var.hub_cidr
  spoke_cidr          = var.spoke_cidr
  tags                = local.tags
}

module "keyvault" {
  source                     = "../../modules/keyvault"
  name                       = "kv-${substr(local.compact, 0, 21)}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  pe_subnet_id               = module.network.pe_subnet_id
  private_dns_zone_id        = module.network.private_dns_zone_ids["keyvault"]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.tags
}

module "acr" {
  source                     = "../../modules/acr"
  name                       = "acr${local.compact}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  pe_subnet_id               = module.network.pe_subnet_id
  private_dns_zone_id        = module.network.private_dns_zone_ids["acr"]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.tags
}

module "postgres" {
  source                     = "../../modules/postgres"
  name                       = "psql-${local.name_suffix}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  sku_name                   = var.postgres_sku
  backup_retention_days      = var.postgres_backup_days
  geo_redundant_backup       = var.postgres_geo_backup
  high_availability          = var.postgres_ha
  delegated_subnet_id        = module.network.postgres_subnet_id
  private_dns_zone_id        = module.network.private_dns_zone_ids["postgres"]
  key_vault_id               = module.keyvault.id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.tags
}

module "appgw" {
  source                     = "../../modules/appgw"
  name_suffix                = local.name_suffix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  subnet_id                  = module.network.appgw_subnet_id
  waf_mode                   = var.waf_mode
  min_capacity               = var.appgw_min_capacity
  max_capacity               = var.appgw_max_capacity
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.tags
}

module "aks" {
  source                     = "../../modules/aks"
  name_suffix                = local.name_suffix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  sku_tier                   = var.aks_sku_tier
  aks_subnet_id              = module.network.aks_subnet_id
  appgw_subnet_id            = module.network.appgw_subnet_id
  application_gateway_id     = module.appgw.id
  acr_id                     = module.acr.id
  key_vault_id               = module.keyvault.id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  admin_group_object_ids     = var.aks_admin_group_ids
  api_authorized_ip_ranges   = var.aks_api_authorized_ip_ranges
  apps_vm_size               = var.aks_apps_vm_size
  apps_min_count             = var.aks_apps_min
  apps_max_count             = var.aks_apps_max
  system_min_count           = var.aks_system_min
  tags                       = local.tags
}

# Budget alert - FinOps guardrail
resource "azurerm_consumption_budget_resource_group" "this" {
  name              = "budget-${local.name_suffix}"
  resource_group_id = azurerm_resource_group.this.id
  amount            = var.monthly_budget_gbp
  time_grain        = "Monthly"

  time_period {
    start_date = "2026-10-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = [var.alert_email]
  }
}
