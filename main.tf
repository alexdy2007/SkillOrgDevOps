terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "postgres" {
  name         = "postgres:13.4"
  keep_locally = true
}

resource "docker_container" "postgres-skill" {
  image = docker_image.postgres.latest
  name  = "postgres-skill"
  ports {
    internal = 5432
    external = 5432
  }
  env = ["POSTGRES_USER=testuser","POSTGRES_PASSWORD=ppppp","POSTGRES_DB=skilldb"]
    
}