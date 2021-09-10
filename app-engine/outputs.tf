output "domain_names" {
  value = var.domain_names
}

output "app_engine_default_service_account" {
  value = data.google_app_engine_default_service_account.default
}
