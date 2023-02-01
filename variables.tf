variable "location" {
  type        = string
  default     = "West Europe"
  description = "Location"
}

variable "cosmosdb-name" {
  type = string
  default = "kn-nosql"
  description = "CosmosDB name"
}

variable "cosmosdb-database-name" {
  type = string
  default = "raw_tweets"
  description = "NoSQL database name"
}

variable "cosmosdb-container-name" {
  type = string
  default = "tweets_db"
  description = "NoSQL container name"
}

variable "max_throughput" {
  type        = number
  description = "Cosmos db database max throughput"
  default = 6000
  validation {
    condition     = var.max_throughput >= 4000 && var.max_throughput <= 1000000
    error_message = "Cosmos db autoscale max throughput should be equal to or greater than 4000 and less than or equal to 1000000."
  }
  validation {
    condition     = var.max_throughput % 100 == 0
    error_message = "Cosmos db max throughput should be in increments of 100."
  }
}
 
# variable "appId" {
#   description = "Azure application ID"
#   type        = string
#   sensitive = true
# }

# variable "displayName" {
#   description = "Display name"
#   type        = string
#   sensitive = true
# }

# variable "password" {
#   description = "Client secret password"
#   type        = string
#   sensitive = true
# }

# variable "tenant" {
#   description = "Tenant ID"
#   type        = string
#   sensitive = true
# }

# variable "azureId" {
#   type        = string
#   description = "Azure id"
#   sensitive = true
# }
