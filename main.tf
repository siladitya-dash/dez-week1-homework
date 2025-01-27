terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

provider "google" {
credentials = "./keys/my-creds.json"
  project = "artful-shelter-449117-r0"
  region  = "us-central1"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "artful-shelter-449117-r0-bucket"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "demo_dataset"
}