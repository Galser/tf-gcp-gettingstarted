# tf-gcp-gettingstarted
TF gettings started - google cloud platform

Not a full-blown repo.

# Instructions

## Setting up GCP

In addition to a GCP account, you'll need two things to use Terraform to provision your infrastructure:

A GCP Project: GCP organizes resources into projects. You can [create one](https://console.cloud.google.com/projectcreate) in the GCP console. You'll need the Project ID later. You can see a list of your projects in the [cloud resource manager](https://console.cloud.google.com/cloud-resource-manager).

Google Compute Engine: You'll need to enable Google Compute Engine for your project. You can do so [in the console](https://console.developers.google.com/apis/library/compute.googleapis.com). Make sure the project you're using to follow this guide is selected and click the "Enable" button.

A GCP service account key: Terraform will access your GCP account by using a service account key. You can [create one](https://console.cloud.google.com/apis/credentials/serviceaccountkey) in the console. When creating the key, use the following settings:

* Select the project you created in the previous step.
* Under "Service account", select "New service account".
* Give it any name you like.
* For the Role, choose "Project -> Editor".
* Leave the "Key Type" as JSON.
* Click "Create" to create the key and save the key file to your system.

You can read more about service account keys in [Google's documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

> NOTE : WARNING: The service account key file provides access to your GCP project. It should be treated like any other secret credentials. Specifically, it should never be checked into source control.

## Build Infrastructure

- main.tf
    ```terraform
    provider "google" {
    credentials = file("~/Keys/tf-gettingstarted-ade17a5d7ec1.json")

    project = "tf-gettingstarted"
    region  = "us-central1"
    zone    = "us-central1-c"
    }

    resource "google_compute_network" "vpc_network" {
    name = "terraform-network"
    }
    ```
- Terraform Init :
    ```bash
    $ terraform init

    Initializing the backend...

    Initializing provider plugins...
    - Checking for available provider plugins...
    - Downloading plugin for provider "google" (hashicorp/google) 2.17.0...

    The following providers do not have any version constraints in configuration,
    so the latest version was installed.

    To prevent automatic upgrades to new major versions that may contain breaking
    changes, it is recommended to add version = "..." constraints to the
    corresponding provider blocks in configuration, with the constraint strings
    suggested below.

    * provider.google: version = "~> 2.17"

    Terraform has been successfully initialized
    ```
- Create resources :
    ```bash
    terraform apply

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # google_compute_network.vpc_network will be created
    + resource "google_compute_network" "vpc_network" {
        + auto_create_subnetworks         = true
        + delete_default_routes_on_create = false
        + gateway_ipv4                    = (known after apply)
        + id                              = (known after apply)
        + name                            = "terraform-network"
        + project                         = (known after apply)
        + routing_mode                    = (known after apply)
        + self_link                       = (known after apply)
        }

    Plan: 1 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

    google_compute_network.vpc_network: Creating...
    google_compute_network.vpc_network: Still creating... [10s elapsed]
    google_compute_network.vpc_network: Still creating... [20s elapsed]
    google_compute_network.vpc_network: Still creating... [30s elapsed]
    google_compute_network.vpc_network: Still creating... [40s elapsed]
    google_compute_network.vpc_network: Creation complete after 48s [id=terraform-network]

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```


# TODO

- [ ] Change Infrastructure
- [ ] Destroy Infrastructure
- [ ] Resource Dependencies
- [ ] Provision
- [ ] Input Variables
- [ ] Output Variables

# DONE
- [x] objectives
- [x] setting up GCP
- [x] Build Infrastructure