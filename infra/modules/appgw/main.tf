resource "azurerm_public_ip" "appgw" {
  name                = "pip-agw-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "this" {
  name                = "waf-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "Microsoft_DefaultRuleSet"
      version = "2.1"
    }
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    }
  }

  custom_rules {
    name                 = "RateLimitPerIP"
    priority             = 10
    rule_type            = "RateLimitRule"
    action               = "Block"
    rate_limit_duration  = "OneMin"
    rate_limit_threshold = 300
    group_rate_limit_by  = "ClientAddr"

    match_conditions {
      match_variables { variable_name = "RemoteAddr" }
      operator           = "IPMatch"
      negation_condition = true
      match_values       = ["255.255.255.255/32"]
    }
  }
}

# AGIC manages listeners/rules after creation; Terraform only bootstraps the gateway.
locals {
  backend_pool = "default-pool"
  http_setting = "default-http"
  listener     = "default-listener"
  fe_ip        = "public-fe"
  fe_port      = "port-80"
}

resource "azurerm_application_gateway" "this" {
  name                = "agw-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = azurerm_web_application_firewall_policy.this.id
  zones               = ["1", "2", "3"]
  tags                = var.tags

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S" # TLS 1.2+ only
  }

  gateway_ip_configuration {
    name      = "gw-ip"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.fe_ip
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = local.fe_port
    port = 80
  }

  backend_address_pool { name = local.backend_pool }

  backend_http_settings {
    name                  = local.http_setting
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = local.listener
    frontend_ip_configuration_name = local.fe_ip
    frontend_port_name             = local.fe_port
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = local.listener
    backend_address_pool_name  = local.backend_pool
    backend_http_settings_name = local.http_setting
  }

  lifecycle {
    ignore_changes = [
      backend_address_pool, backend_http_settings, http_listener, probe,
      request_routing_rule, frontend_port, ssl_certificate, redirect_configuration,
      url_path_map, tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "appgw" {
  name                       = "diag-agw-${var.name_suffix}"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "ApplicationGatewayAccessLog" }
  enabled_log { category = "ApplicationGatewayFirewallLog" }
  enabled_metric { category = "AllMetrics" }
}
