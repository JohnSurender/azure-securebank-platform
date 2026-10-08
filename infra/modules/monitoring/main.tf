resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "oncall" {
  name                = "ag-oncall-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  short_name          = "oncall"

  email_receiver {
    name          = "platform-team"
    email_address = var.alert_email
  }
}
