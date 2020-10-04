locals {
  domain_names_set = toset(var.domain_names)
}

data "archive_file" "artifact" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${var.source_dir}.zip"
}

data "google_dns_managed_zone" "zone" {
  project = var.dns_project_id
  name    = var.dns_zone
}

resource "google_app_engine_application" "app" {
  count       = var.service == "default" ? 1 : 0
  project     = var.project
  location_id = var.location
}

resource "google_storage_bucket" "artifacts" {
  project  = var.project
  location = var.bucket_location
  name     = "${var.project}-${var.service}-artifacts"
}

resource "google_storage_bucket_object" "artifact" {
  name   = "artifact-${data.archive_file.artifact.output_md5}"
  bucket = google_storage_bucket.artifacts.name
  source = data.archive_file.artifact.output_path
}

resource "google_app_engine_standard_app_version" "app" {

  service       = var.service
  version_id    = var.version_id
  project       = var.project
  runtime       = var.runtime
  env_variables = var.env_variables

  delete_service_on_destroy = true

  entrypoint {
    shell = var.entrypoint
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket_object.artifact.bucket}/${google_storage_bucket_object.artifact.name}"
    }
  }

  automatic_scaling {
    max_concurrent_requests = 10
    min_idle_instances      = 1
    max_idle_instances      = 3
    min_pending_latency     = "1s"
    max_pending_latency     = "5s"

    standard_scheduler_settings {
      target_cpu_utilization        = 0.5
      target_throughput_utilization = 0.75
      min_instances                 = 2
      max_instances                 = 10
    }
  }

}

resource "google_app_engine_domain_mapping" "app" {
  project     = var.project
  for_each    = local.domain_names_set
  domain_name = each.value

  ssl_settings {
    ssl_management_type = "AUTOMATIC"
  }

}

resource "google_dns_record_set" "dns" {
  project  = var.dns_project_id
  for_each = local.domain_names_set

  depends_on = [
    google_app_engine_domain_mapping.app
  ]

  type         = "CNAME"
  name         = "${each.value}."
  managed_zone = data.google_dns_managed_zone.zone.name
  ttl          = 600

  rrdatas = [
    "ghs.googlehosted.com."
  ]
}

