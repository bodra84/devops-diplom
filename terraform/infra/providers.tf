terraform {
  required_version = "~>1.8.4"

  backend "s3" {

    shared_credentials_files = ["../S3_bucket_SA/.credentials"]
    shared_config_files      = ["../S3_bucket_SA/config"]
    profile                  = "default"
    region                   = "ru-central1"

    bucket = "faizievbucket"
    key    = "diplom/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
  }

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.118.0"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = file("../S3_bucket_SA/.auth-key.json")
}
