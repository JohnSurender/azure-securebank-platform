terraform {
  backend "azurerm" {
    resource_group_name  = "rg-securebank-tfstate-uks"
    storage_account_name = "stsecurebanktfXXXXX" # replace with output of bootstrap/01-create-tfstate.sh
    container_name       = "tfstate"
    key                  = "securebank-dev.tfstate"
    use_azuread_auth     = true
  }
}
