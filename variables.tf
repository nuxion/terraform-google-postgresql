variable "project_id" {
  description = "GCP Project ID"
  type = string
}

variable "bucket" {
  description = "full bucket path to be used by postegresql"
  type = string
}

variable "script_install" {
  description = "startup script for Postgresql installation"
  type = string
  default = "files/postgres_install.sh"
}


variable "service_account" {
  type = string
  description = "SA Account associated to the instance"
  default = "dbmanager"
}

variable "server_scopes" {
  type = list
  description = "Scopes to be configurated when creation the instance"
  default = ["cloud-platform"]
}

variable "network_tags" {
  type = list
  description = "Network tags to use for the instance (firewall related)"
  default = ["db", "default"]
}

variable "label_env" {
  description = "Label environment"
  type = string
  default = "prod"
}

variable "server_name" {
  description = "hostname for the server"
  type = string
  default = "db"

}

variable "server_zone" {
  description = "zone for this server"
  type = string
}

variable "server_machine_type" {
  description = "GCP type machine"
  type = string
  default = "e2-medium"
}

variable "server_boot_image" {
  description = "Boot Disk Image"
  type = string
  default = "debian-cloud/debian-11"
}

variable "server_boot_size" {
  description = "Boot Disk Size"
  type = string
  default = "10"
}

variable "server_boot_type" {
  description = "Boot Disk Type"
  type = string
  default = "pd-standard"
}

variable "network_name" {
  description = "Network to attach"
  type = string
  default = "default"
}

variable "postgresql_version" {
  description = "postgresql version to install"
  type = string
  default = "14"
}

variable "pg_config_file" {
  description = "local config file for postgresql"
  type = string
  default = "config.yaml"
}
