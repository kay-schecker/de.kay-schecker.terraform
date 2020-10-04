variable "dns_project_id" {
  default     = "de-kay-schecker-dns-0c1d"
  description = "The project where to add the DNS record(s)"
}

variable "dns_zone" {
  default     = "kay-schecker"
  description = "The zone where to add the DNS record(s)"
}

variable "service" {
  default = "default"
}

variable "location" {
  default = "europe-west3"
}

variable "env_variables" {
  default = {}
}

variable "entrypoint" {
  default = "npm start"
}

variable "version_id" {
  default = "v1"
}

variable "runtime" {
  default = "nodejs12"
}

variable "bucket_location" {
  type    = string
  default = "europe-west3"
}

variable "project" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "domain_names" {
  type = list(string)
}
