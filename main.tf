terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.41"
      }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }  
}

# AZURE
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "krg" {
  name     = "kevinBoumanResourceGroup"
  location = var.location
}

resource "azurerm_cosmosdb_account" "kn-cosmosdb" {
  name                      = "kn-nosql"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.krg.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  geo_location {
    location          = var.location
    failover_priority = 0
  }
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  depends_on = [
    azurerm_resource_group.krg
  ]
}

resource "azurerm_cosmosdb_sql_database" "kn-database" {
  name                = var.cosmosdb-database-name
  resource_group_name = azurerm_resource_group.krg.name
  account_name        = azurerm_cosmosdb_account.kn-cosmosdb.name
  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

resource "azurerm_cosmosdb_sql_container" "kn-container" {
  name                  = var.cosmosdb-container-name
  resource_group_name   = azurerm_resource_group.krg.name
  account_name          = azurerm_cosmosdb_account.kn-cosmosdb.name
  database_name         = azurerm_cosmosdb_sql_database.kn-database.name
  partition_key_path    = "/id"
  partition_key_version = 1
  autoscale_settings {
    max_throughput = var.max_throughput
  }

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }
}

resource "azurerm_postgresql_server" "psqlserver" {
  name                = "kn-psql-server"
  location            = azurerm_resource_group.krg.location
  resource_group_name = azurerm_resource_group.krg.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "citus"
  administrator_login_password = "3HBDzBXjTWhgVQQCywdb"
  version                      = "11"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "kn-psql-db" {
  name                = "citus"
  resource_group_name = azurerm_resource_group.krg.name
  server_name         = azurerm_postgresql_server.psqlserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}


resource "azurerm_container_registry" "kn-acr" {
  name                = "knacr"
  resource_group_name = azurerm_resource_group.krg.name
  location            = azurerm_resource_group.krg.location
  sku                 = "Premium"
  admin_enabled       = false
}

# # DOCKER
# provider "docker" {
#   host = "unix:///var/run/docker.sock"
# }

# # Pulls the image
# resource "docker_image" "server" {
#   name = "twitter_server:latest"
# }

# # Create a container
# resource "docker_container" "myserver" {
#   image = docker_image.server.image_id
#   name  = "myserver-container"
# }

# # Pulls the image
# resource "docker_image" "client" {
#   name = "twitter_client:latest"
# }

# # Create a container
# resource "docker_container" "myclient" {
#   image = docker_image.client.image_id
#   name  = "myclient-container"
# }