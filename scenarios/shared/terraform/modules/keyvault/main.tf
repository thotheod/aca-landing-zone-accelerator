data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                            = var.keyVaultName
  resource_group_name             = var.resourceGroupName
  location                        = var.location
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  public_network_access_enabled   = true # todo false
  enable_rbac_authorization       = true
  enabled_for_template_deployment = true
  tags                            = var.tags

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = [var.clientIP]
    virtual_network_subnet_ids = null
  }
}

module "keyVaultPrivateZones" {
  source            = "../networking/private-zones"
  resourceGroupName = var.resourceGroupName
  vnetLinks         = var.vnetLinks
  zoneName          = local.privateDnsZoneNames
  records           = var.aRecords
  tags              = var.tags
}

module "keyVaultPrivateEndpoints" {
  source            = "../networking/private-endpoints"
  endpointName      = var.keyVaultPep
  resourceGroupName = var.resourceGroupName
  subnetId          = var.subnetId
  privateLinkId     = azurerm_key_vault.keyvault.id
  privateDnsZoneIds = [module.keyVaultPrivateZones.privateDnsZoneId]
  subResourceNames  = local.subResourceNames
  tags              = var.tags
}

resource "azurerm_user_assigned_identity" "keyVaultUserAssignedIdentity" {
  name                = var.keyVaultUserAssignedIdentityName
  resource_group_name = var.resourceGroupName
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "keyVaultPullRoleAssignment" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_user_assigned_identity.keyVaultUserAssignedIdentity.principal_id
}

# enable user to read/write secrets
resource "azurerm_role_assignment" "keyVaultSecretsOfficerRoleAssignment" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}