variable "workloadName" {
  type = string
  validation {
    condition     = length(var.workloadName) >= 2 && length(var.workloadName) <= 10
    error_message = "Name must be greater at least 2 characters and not greater than 10."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = length(var.environment) <= 8
    error_message = "Environment name can't be greater than 8 characters long."
  }
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "hubResourceGroupName" {}

variable "tags" {}

variable "vnetAddressPrefixes" {}

variable "enableBastion" {
  default = true
  type    = bool
}

variable "bastionSubnetAddressPrefixes" {}

variable "vmSize" {}

variable "vmAdminUsername" {
  default = "vmadmin"
}

variable "vmAdminPassword" {
  sensitive = true
}

variable "vmLinuxSshAuthorizedKeys" {}

variable "vmJumpboxOSType" {
  default = "Linux"
  validation {
    condition = anytrue([
      var.vmJumpboxOSType == "Linux",
      var.vmJumpboxOSType == "Windows"
    ])
    error_message = "OS Type must be Linux or Windows."
  }
}

variable "vmSubnetName" {
  default = "snet-jumpbox"
  type    = string
}

variable "ddosProtectionPlanId" {
  default = null
  type    = string
}

variable "securityRules" {
  default = []
}

variable "vmJumpBoxSubnetAddressPrefix" {}