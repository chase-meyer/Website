# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.1"
    }
  }

  required_version = ">= 1.1.0"
}

# Variables (you can modify these values or move them to a variables.tf file)
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "hugo-blog-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account"
  type        = string
  default     = "hugoblogstorageacct"
}

variable "container_name" {
  description = "Name of the blob storage container"
  type        = string
  default     = "www"
}

variable "index_document" {
  description = "The index document for the static site"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The error document for the static site"
  type        = string
  default     = "404.html"
}

# Create Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Storage Account
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name       = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true

  tags = {
    environment = "production"
  }
}

# Configure Static Website Hosting in Storage Account
resource "azurerm_storage_account_static_website" "example" {
  storage_account_id = azurerm_storage_account.example.id
  index_document     = var.index_document
  error_document     = var.error_document
}

# Create a Blob Container (where your website files will be stored)
resource "azurerm_storage_container" "example" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob"
}

# Outputs for accessing the deployed website
output "website_url" {
  value = azurerm_storage_account_static_website.example.primary_web_endpoint
  description = "The URL of the static website"
}

output "storage_account_name" {
  value = azurerm_storage_account.example.name
  description = "The name of the Azure Storage Account"
}

output "container_name" {
  value = azurerm_storage_container.example.name
  description = "The name of the storage container"
}