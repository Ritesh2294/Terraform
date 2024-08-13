data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.105"
    }

    azapi = {
      source  = "Azure/azapi"
      
    }
  }
}

provider "azurerm" {
  features {}
  partner_id = "754599a0-0a6f-424a-b4c5-1b12be198ae8"
}
locals {
 
  telem_arm_subscription_template_content = <<TEMPLATE
    {
      "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {},
      "variables": {},
      "resources": [],
      "outputs": {
        "telemetry": {
          "type": "String",
          "value": "For more information, see https://aka.ms/alz/tf/telemetry"
        }
      }
    }
    TEMPLATE
  module_identifier                       = lower("avs_greenfield_standard")
  telem_arm_deployment_name               = "754599a0-0a6f-424a-b4c5-1b12be198ae8.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
}

#create a random string for uniqueness  
resource "random_string" "telemetry" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_subscription_template_deployment" "telemetry_core" {
  # count = var.telemetry_enabled ? 1 : 0

  name             = local.telem_arm_deployment_name
  provider         = azurerm
  location         = azurerm_vmware_private_cloud.privatecloud.location
  template_content = local.telem_arm_subscription_template_content
}
