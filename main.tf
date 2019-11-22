provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}


#resource "google_compute_network" "vpc_network" {
#  name = "terraform-network"
#}


resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  
  network_interface {
#    network = google_compute_network.vpc_network.self_link
    network    = module.network.network_name
    subnetwork = module.network.subnets_names[0]    
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }
}


module "network" {
  source  = "terraform-google-modules/network/google"
  version = "1.1.0"

  network_name = "terraform-vpc-network"
  project_id   = var.project

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = var.cidrs[0]
      subnet_region = var.region
    },
    {
      subnet_name   = "subnet-02"
      subnet_ip     = var.cidrs[1]
      subnet_region = var.region

      subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    subnet-01 = []
    subnet-02 = []
  }
}


## 



resource "google_compute_instance_template" "template_three_disk" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]

  labels = {
      environment = "dev"
      purpose     = "coffe_break"
    }

  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    disk_size_gb = 100
    boot         = true
  }

  network_interface {
#    network = google_compute_network.vpc_network.self_link
    network    = module.network.network_name
    subnetwork = module.network.subnets_names[0]    
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }

  can_ip_forward = true
}

resource "google_compute_instance_from_template" "test" {
  name = "instance-from-template"
  #zone = "us-central1-a"

  source_instance_template = google_compute_instance_template.template_three_disk.self_link

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }


  // Override fields from instance template
  can_ip_forward = false
  labels = {
    purpose = "go_west"
  }
}