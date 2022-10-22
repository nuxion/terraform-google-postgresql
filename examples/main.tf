provider "google" {
  region      = "${var.region}"
  project     = "${var.project_id}"
}

module "db" {
  source = "../"
  server_boot_image = "debian-11-bullseye-v20220406"
  server_boot_size = 10
  server_zone="${var.zone}"
  network_name="prod"
  project_id = "${var.project_id}"
}
