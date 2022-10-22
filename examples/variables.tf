variable "project_id" {
  description = "GCP Project ID"
  type = string
}

variable "zone" {
  description = "Zone is the complete name as 'us-central1-a'"
  type = string
  default = "us-central1-a"
}


variable "region" {
  type = string
  description = "region is more general area like 'us-central1'"
  default = "us-central1"
}

