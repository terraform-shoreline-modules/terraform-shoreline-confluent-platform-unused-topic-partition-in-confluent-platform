terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "unused_topic_partition_in_confluent_platform" {
  source    = "./modules/unused_topic_partition_in_confluent_platform"

  providers = {
    shoreline = shoreline
  }
}