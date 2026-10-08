resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Control-plane identity needs Network Contributor on the node subnet
resource "azurerm_role_assignment" "aks_network" {
  scope                = var.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.name_suffix}"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  tags                = var.tags

  # Security hardening
  local_account_disabled            = true
  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  azure_policy_enabled              = true
  automatic_upgrade_channel         = "patch"
  node_os_upgrade_channel           = "NodeImage"
  image_cleaner_enabled             = true
  image_cleaner_interval_hours      = 48

  api_server_access_profile {
    authorized_ip_ranges = var.api_authorized_ip_ranges
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_vm_size
    vnet_subnet_id               = var.aks_subnet_id
    auto_scaling_enabled         = true
    min_count                    = var.system_min_count
    max_count                    = var.system_max_count
    zones                        = ["1", "2", "3"]
    only_critical_addons_enabled = true
    os_sku                       = "AzureLinux"
    max_pods                     = 50
    upgrade_settings { max_surge = "33%" }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  microsoft_defender {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  ingress_application_gateway {
    gateway_id = var.application_gateway_id
  }

  depends_on = [azurerm_role_assignment.aks_network]
}

resource "azurerm_kubernetes_cluster_node_pool" "apps" {
  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.apps_vm_size
  vnet_subnet_id        = var.aks_subnet_id
  auto_scaling_enabled  = true
  min_count             = var.apps_min_count
  max_count             = var.apps_max_count
  zones                 = ["1", "2", "3"]
  os_sku                = "AzureLinux"
  node_labels           = { workload = "banking" }
  tags                  = var.tags
  upgrade_settings { max_surge = "33%" }
}

# Kubelet may pull from ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

# AGIC identity needs Contributor on App Gateway and Reader on its RG
resource "azurerm_role_assignment" "agic_appgw" {
  scope                = var.application_gateway_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "agic_subnet" {
  scope                = var.appgw_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

# Workload identity for banking services -> Key Vault secrets
resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-workload-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "workload" {
  for_each            = toset(var.workload_service_accounts)
  name                = "fic-${each.value}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.workload.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  subject             = "system:serviceaccount:securebank:${each.value}"
}

resource "azurerm_role_assignment" "workload_kv" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}
