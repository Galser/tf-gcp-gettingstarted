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

- Contents of [main.tf](main.tf) :
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

## Change Infrastructure

- Added contents to [main.tf](main.tf) :
    ```terraform
    ...
    resource "google_compute_instance" "vm_instance" {
        name         = "terraform-instance"
        machine_type = "f1-micro"

        boot_disk {
            initialize_params {
            image = "debian-cloud/debian-9"
            }
        }

        network_interface {
            network = google_compute_network.vpc_network.name
            access_config {
            }
        }
    }
    ```
- Running `terraform apply` : 
    ```
    google_compute_instance.vm_instance: Creating...
    google_compute_instance.vm_instance: Still creating... [10s elapsed]
    google_compute_instance.vm_instance: Creation complete after 12s [id=terraform-instance]

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```
- Adding new resources is one thing. Terraform also supports changing resources. Add a "tags" argument to your "vm_instance" so that it looks like this:
- Added contents to [main.tf](main.tf) :
    ```terraform
    ...
    resource "google_compute_instance" "vm_instance" {
        name         = "terraform-instance"
        machine_type = "f1-micro"
        tags         = ["web", "dev"]
    ...
    ```
- Running `terraform apply` again : 
    ```
    ...
      ~ tags                 = [
          + "dev",
          + "web",
        ]
    ...
    Plan: 0 to add, 1 to change, 0 to destroy.

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

    google_compute_instance.vm_instance: Modifying... [id=terraform-instance]
    google_compute_instance.vm_instance: Still modifying... [id=terraform-instance, 10s elapsed]
    google_compute_instance.vm_instance: Modifications complete after 13s [id=terraform-instance]

    Apply complete! Resources: 0 added, 1 changed, 0 destroyed    
    ```

### Destructive changes

- Let's change the disk image of our instance. Edit the boot_disk block inside your `vm_instance` resource your configuration file and change it to the following: 
    ```terraform
    ...
    boot_disk {
        initialize_params {
        image = "cos-cloud/cos-stable"
        }
    }
    ...
    ```
- We've changed the boot disk from being a Debian 9 image to use Google's Container-Optimized OS. After editing the configuration, run terraform apply again to see how Terraform will apply this change to the existing resources. Running `terraform apply` :
  ```bash
  google_compute_network.vpc_network: Refreshing state... [id=terraform-network]
  google_compute_instance.vm_instance: Refreshing state... [id=terraform-instance]

  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
  -/+ destroy and then create replacement

  Terraform will perform the following actions:

    # google_compute_instance.vm_instance must be replaced
  -/+ resource "google_compute_instance" "vm_instance" {
          can_ip_forward       = false
        ~ cpu_platform         = "Intel Haswell" -> (known after apply)
          deletion_protection  = false
        ~ guest_accelerator    = [] -> (known after apply)
        ~ id                   = "terraform-instance" -> (known after apply)
        ~ instance_id          = "2878235295815000323" -> (known after apply)
        ~ label_fingerprint    = "42WmSpB8rSM=" -> (known after apply)
        - labels               = {} -> null
          machine_type         = "f1-micro"
        - metadata             = {} -> null
        ~ metadata_fingerprint = "boRsKp9gCGU=" -> (known after apply)
          name                 = "terraform-instance"
        ~ project              = "tf-gettingstarted" -> (known after apply)
        ~ self_link            = "https://www.googleapis.com/compute/v1/projects/tf-gettingstarted/zones/us-central1-c/instances/terraform-instance" -> (known after apply)
          tags                 = [
              "dev",
              "web",
          ]
        ~ tags_fingerprint     = "XaeQnaHMn9Y=" -> (known after apply)
        ~ zone                 = "us-central1-c" -> (known after apply)

        ~ boot_disk {
              auto_delete                = true
            ~ device_name                = "persistent-disk-0" -> (known after apply)
            + disk_encryption_key_sha256 = (known after apply)
            + kms_key_self_link          = (known after apply)
              mode                       = "READ_WRITE"
            ~ source                     = "https://www.googleapis.com/compute/v1/projects/tf-gettingstarted/zones/us-central1-c/disks/terraform-instance" -> (known after apply)

            ~ initialize_params {
                ~ image  = "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-9-stretch-v20191014" -> "cos-cloud/cos-stable" # forces replacement
                ~ labels = {} -> (known after apply)
                ~ size   = 10 -> (known after apply)
                ~ type   = "pd-standard" -> (known after apply)
              }
          }
  ...
  google_compute_instance.vm_instance: Destroying... [id=terraform-instance]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 10s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 20s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 30s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 40s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 50s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m0s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m10s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m20s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m30s elapsed]
  google_compute_instance.vm_instance: Destruction complete after 1m39s
  google_compute_instance.vm_instance: Creating...
  google_compute_instance.vm_instance: Still creating... [10s elapsed]
  google_compute_instance.vm_instance: Creation complete after 19s [id=terraform-instance]

  Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
  ```

## Destroy Infrastructure
- Running `terraform destroy` : 
  ```bash
  google_compute_instance.vm_instance: Destroying... [id=terraform-instance]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 10s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 20s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 30s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 40s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 50s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m0s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m10s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m20s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m30s elapsed]
  google_compute_instance.vm_instance: Still destroying... [id=terraform-instance, 1m40s elapsed]
  google_compute_instance.vm_instance: Destruction complete after 1m49s
  google_compute_network.vpc_network: Destroying... [id=terraform-network]
  google_compute_network.vpc_network: Still destroying... [id=terraform-network, 10s elapsed]
  google_compute_network.vpc_network: Still destroying... [id=terraform-network, 20s elapsed]
  google_compute_network.vpc_network: Still destroying... [id=terraform-network, 30s elapsed]
  google_compute_network.vpc_network: Still destroying... [id=terraform-network, 40s elapsed]
  google_compute_network.vpc_network: Still destroying... [id=terraform-network, 50s elapsed]
  google_compute_network.vpc_network: Still destroying... [id=terraform-network, 1m0s elapsed]
  google_compute_network.vpc_network: Destruction complete after 1m8s

  Destroy complete! Resources: 2 destroyed.  
  ```

## Resource Dependencies
- Now we'll improve your configuration by assigning a static IP to the VM instance we're managing. Modify your [main.tf](main.tf) and add the following:
  ```terraform
  resource "google_compute_address" "vm_static_ip" {
    name = "terraform-static-ip"
  }
  ```
- This should look familiar from the earlier example of adding a VM instance resource, except this time we're creating an "google_compute_address" resource type. This resource type allocates a reserved IP address to your project. You can see what will be created with terraform plan:
  ```bash
  terraform plan 
  Refreshing Terraform state in-memory prior to plan...
  The refreshed state will be used to calculate this plan, but will not be
  persisted to local or remote state storage.

  google_compute_network.vpc_network: Refreshing state... [id=terraform-network]
  google_compute_instance.vm_instance: Refreshing state... [id=terraform-instance]

  ------------------------------------------------------------------------

  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
    + create

  Terraform will perform the following actions:

    # google_compute_address.vm_static_ip will be created
    + resource "google_compute_address" "vm_static_ip" {
        + address            = (known after apply)
        + address_type       = "EXTERNAL"
        + creation_timestamp = (known after apply)
        + id                 = (known after apply)
        + name               = "terraform-static-ip"
        + network_tier       = (known after apply)
        + project            = (known after apply)
        + purpose            = (known after apply)
        + region             = (known after apply)
        + self_link          = (known after apply)
        + subnetwork         = (known after apply)
        + users              = (known after apply)
      }

  Plan: 1 to add, 0 to change, 0 to destroy.

  ------------------------------------------------------------------------

  Note: You didn't specify an "-out" parameter to save this plan, so Terraform
  can't guarantee that exactly these actions will be performed if
  "terraform apply" is subsequently run.
  ```
- Now, before applying. let's update  the `network_interface` configuration for your instance like so:
  ```terraform
    network_interface {
      network = google_compute_network.vpc_network.self_link
      access_config {
        nat_ip = google_compute_address.vm_static_ip.address
      }
    }
  ```
- We'll run terraform plan again, but this time, let's save the plan:
  ```bash
  $ terraform plan -out static_ip

  Refreshing Terraform state in-memory prior to plan...
  The refreshed state will be used to calculate this plan, but will not be
  persisted to local or remote state storage.

  google_compute_network.vpc_network: Refreshing state... [id=terraform-network]
  google_compute_instance.vm_instance: Refreshing state... [id=terraform-instance]

  ------------------------------------------------------------------------

  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
    + create
    ~ update in-place

  ...
    # google_compute_instance.vm_instance will be updated in-place
    ~ resource "google_compute_instance" "vm_instance" {
          can_ip_forward       = false
          cpu_platform         = "Intel Haswell"
  ...
        ~ network_interface {
              name               = "nic0"
              network            = "https://www.googleapis.com/compute/v1/projects/tf-gettingstarted/global/networks/terraform-network"
              network_ip         = "10.128.0.2"
              subnetwork         = "https://www.googleapis.com/compute/v1/projects/tf-gettingstarted/regions/us-central1/subnetworks/terraform-network"
              subnetwork_project = "tf-gettingstarted"

            ~ access_config {
                ~ nat_ip       = "34.67.7.20" -> (known after apply)
  ...
  Plan: 1 to add, 1 to change, 0 to destroy.

  ------------------------------------------------------------------------

  This plan was saved to: static_ip

  To perform exactly these actions, run the following command to apply:
      terraform apply "static_ip"
  ```
  Saving the plan this way ensures that we can apply exactly the same plan in the future. If we try to apply the file created by the plan, Terraform will first check to make sure the exact same set of changes will be made before applying the plan.

  In this case, we can see that Terraform will create a new `google_compute_address` and update the existing VM to use it.
- Run `terraform apply "static_ip"` to see how Terraform plans to apply this change. The output will look similar to the following:
  ```bash
  google_compute_address.vm_static_ip: Creating...
  google_compute_address.vm_static_ip: Creation complete after 5s [id=tf-gettingstarted/us-central1/terraform-static-ip]
  google_compute_instance.vm_instance: Modifying... [id=terraform-instance]
  google_compute_instance.vm_instance: Still modifying... [id=terraform-instance, 10s elapsed]
  google_compute_instance.vm_instance: Still modifying... [id=terraform-instance, 20s elapsed]
  google_compute_instance.vm_instance: Still modifying... [id=terraform-instance, 30s elapsed]
  google_compute_instance.vm_instance: Modifications complete after 34s [id=terraform-instance]

  Apply complete! Resources: 1 added, 1 changed, 0 destroyed.

  The state of your infrastructure has been saved to the path
  below. This state is required to modify and destroy your
  infrastructure, so keep it safe. To inspect the complete state
  use the `terraform show` command.

  State path: terraform.tfstate
  ```
### Implicit and Explicit Dependencies
By studying the resource attributes used in interpolation expressions, Terraform can automatically infer when one resource depends on another. In the example above, the reference to `google_compute_address.vm_static_ip.address` creates an *implicit dependency* on the `google_compute_address` named `vm_static_ip`.

Terraform uses this dependency information to determine the correct order in which to create and update different resources. In the example above, Terraform knows that the `vm_static_ip` must be created before the `vm_instance` is updated to use it.

Implicit dependencies via interpolation expressions are the primary way to inform Terraform about these relationships, and should be used whenever possible.

Sometimes there are dependencies between resources that are not visible to Terraform. The `depends_on` argument is accepted by any resource and accepts a list of resources to create *explicit dependencies* for.

For example, perhaps an application we will run on our instance expects to use a specific Cloud Storage bucket, but that dependency is configured inside the application code and thus not visible to Terraform. In that case, we can use `depends_on` to explicitly declare the dependency:
  ```terraform
  # New resource for the storage bucket our application will use.
  resource "google_storage_bucket" "example_bucket" {
    name     = "terraform-example-bucket-galser-20191016-01"
    location = "US"

    website {
      main_page_suffix = "index.html"
      not_found_page   = "404.html"
    }
  }

  # Create a new instance that uses the bucket
  resource "google_compute_instance" "another_instance" {
    # Tells Terraform that this VM instance must be created only after the
    # storage bucket has been created.
    depends_on = [google_storage_bucket.example_bucket]

    name         = "terraform-instance-2"
    machine_type = "f1-micro"

    boot_disk {
      initialize_params {
        image = "cos-cloud/cos-stable"
      }
    }

    network_interface {
      network = google_compute_network.vpc_network.self_link
      access_config {
      }
    }
  }
  ```
- `terraform apply` "
```
...
google_storage_bucket.example_bucket: Creating...
google_storage_bucket.example_bucket: Creation complete after 1s [id=terraform-example-bucket-galser-20191016-01]
google_compute_instance.another_instance: Creating...
google_compute_instance.another_instance: Still creating... [10s elapsed]
google_compute_instance.another_instance: Creation complete after 11s [id=terraform-instance-2]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```
- And we need to remove them (2 last resources ) before next part. 


# TODO


- [ ] Provision
- [ ] Input Variables
- [ ] Output Variables

# DONE
- [x] objectives
- [x] setting up GCP
- [x] Build Infrastructure
- [x] Change Infrastructure
- [x] Destroy Infrastructure
- [x] Resource Dependencies
