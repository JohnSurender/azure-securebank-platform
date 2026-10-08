# Hub-and-spoke network: hub hosts App Gateway + Bastion, spoke hosts AKS and data tier.
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.hub_cidr]
  tags                = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.spoke_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_cidr, 8, 1)]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_cidr, 10, 8)]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(var.spoke_cidr, 4, 0)]
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = "snet-pe"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.spoke.name
  address_prefixes                  = [cidrsubnet(var.spoke_cidr, 8, 32)]
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "postgres" {
  name                 = "snet-postgres"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(var.spoke_cidr, 8, 33)]

  delegation {
    name = "postgres-flex"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

# NSG for the private-endpoint subnet: only AKS subnet may reach data services.
resource "azurerm_network_security_group" "pe" {
  name                = "nsg-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-aks-to-pe"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = azurerm_subnet.aks.address_prefixes[0]
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["443", "5432"]
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.pe.id
}

# Private DNS zones for Private Link services
locals {
  private_dns_zones = {
    keyvault = "privatelink.vaultcore.azure.net"
    acr      = "privatelink.azurecr.io"
    postgres = "privatelink.postgres.database.azure.com"
  }
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each              = azurerm_private_dns_zone.this
  name                  = "link-${each.key}-spoke"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}
