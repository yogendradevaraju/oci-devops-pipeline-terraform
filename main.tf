terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  region              = var.region
  auth                = "SecurityToken"
  config_file_profile = "oci-devops-terraform"
}

resource "oci_ons_notification_topic" "custom_image_notification_topic" {
  compartment_id = var.compartment_id
  name = "custom-image-pipeline-topic"
}

resource "oci_logging_log_group" "test_log_group" {
    compartment_id = var.compartment_id
    display_name = "custom-image-pipeline-container"
}

resource "oci_devops_project" "image_builder" {
  compartment_id = var.compartment_id
  name   = "oci-custom-image-pipeline-terraform"
  description = "Pipeline to build custom-image"
  notification_config {
        topic_id = oci_ons_notification_topic.custom_image_notification_topic.id
    }
}

resource "oci_kms_vault" "github_pat_vault_terraform" {
    compartment_id = var.compartment_id
    display_name = "github-pat-vault-terraform"
    vault_type = "DEFAULT"
}

resource "oci_kms_key" "github_pat_key_terraform" {
    compartment_id = var.compartment_id
    display_name = "github-pat-kms"
    key_shape {
        algorithm = var.key_key_shape_algorithm
        length = var.key_key_shape_length
    }
    management_endpoint = oci_kms_vault.github_pat_vault_terraform.management_endpoint
    protection_mode = var.key_protection_mode
}

# create PAT resource before building github connection 
resource "oci_vault_secret" "github_pat_terraform" {
  compartment_id = var.compartment_id
  key_id = oci_kms_key.github_pat_key_terraform.id
  secret_name = "github-pat-terraform"
  vault_id = oci_kms_vault.github_pat_vault_terraform.id
  secret_content {
    content_type = var.secret_secret_content_content_type
    content = var.secret_secret_content_content
  }
}

resource "oci_devops_connection" "github_connection_terraform" {
  connection_type = var.connection_type
  project_id = oci_devops_project.image_builder.id
  access_token = oci_vault_secret.github_pat_terraform.id

  display_name = "GitHub-connection-terraform"
}

resource "oci_devops_repository" "oci_hpc_images_terraform" {
  name = "oci-hpc-images-terraform"
  project_id = oci_devops_project.image_builder.id
  repository_type = "MIRRORED"

  default_branch = "refs/heads/master"
  description = "oci-hpc-images mirrored github repository"
  mirror_repository_config {
      connector_id = oci_devops_connection.github_connection_terraform.id
      repository_url = var.repository_mirror_repository_config_repository_url
      trigger_schedule {
          schedule_type = var.repository_mirror_repository_config_trigger_schedule_schedule_type
      }
  }

  lifecycle {
    ignore_changes = [
      mirror_repository_config
    ]
  }
}

resource "oci_devops_build_pipeline" "custom_image_pipeline_terraform" {
    project_id = oci_devops_project.image_builder.id
    description = "pipeline for the custom-image"
    display_name = "custom-image-pipeline-terraform"
}

resource "oci_devops_build_pipeline_stage" "custom_build_stage" {
  build_pipeline_id = oci_devops_build_pipeline.custom_image_pipeline_terraform.id

  build_pipeline_stage_predecessor_collection {
    items {
      # For first stage, predecessor is the pipeline itself
      id = oci_devops_build_pipeline.custom_image_pipeline_terraform.id
    }
  }

  build_pipeline_stage_type = "BUILD"

  build_source_collection {
    items {
      connection_type = "GITHUB"
      branch          = "master"
      connection_id   = oci_devops_connection.github_connection_terraform.id
      name            = "Source-1"
      repository_id   = oci_devops_repository.oci_hpc_images_terraform.id
      repository_url  = var.repository_mirror_repository_config_repository_url
    }
  }
  build_spec_file = "/build_spec.yaml"
  description  = "First build stage in pipeline"
  display_name = "Custom Build Stage"
  image = "OL8_X86_64_STANDARD_10"
}

####Creating a trigger using terraform doesn't provide the secret and it appears only once when created in the console
# resource "oci_devops_trigger" "custom_image_pipeline_terraform_trigger_test" {
#     #Required
#     actions {
#         #Required
#         build_pipeline_id = oci_devops_build_pipeline.custom_image_pipeline_terraform.id
#         type = "TRIGGER_BUILD_PIPELINE"

#         #Optional
#         filter {
#             #Required
#             trigger_source = "GITHUB"

#             #Optional
#             events = ["PUSH", "PULL_REQUEST_MERGED"]
#             include {

#                 #Optional
#                 base_ref = "master"
#                 head_ref = "*"
#                 repository_name = oci_devops_repository.oci_hpc_images_terraform.name
#             }
#         }
#     }
#     project_id = oci_devops_project.image_builder.id
#     trigger_source = "GITHUB"
#     connection_id = oci_devops_connection.github_connection_terraform.id

#     #Optional
#     description = "Trigger pipeline on GitHub merge to master"
#     display_name = "custom-image-pipeline-terraform-trigger"
# }

###Enable logging in the oci console with the log group created
