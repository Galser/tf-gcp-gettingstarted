provider "google" {
  credentials = file("~/Keys/tf-gettingstarted-ade17a5d7ec1.json")

  project = "tf-gettingstarted"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
