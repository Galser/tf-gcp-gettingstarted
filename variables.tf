

variable "project" {
  default = "tf-gettingstarted"
}

variable "credentials_file" {
  default = "~/Keys/tf-gettingstarted-ade17a5d7ec1.json"

}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "cidrs" {
  default = ["10.0.0.0/16", "10.1.0.0/16"]
}

