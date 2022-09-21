terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }

  required_version = ">= 0.14"
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = "${var.region}-a"
  credentials = file("../contrib/sa/sales.json")
}