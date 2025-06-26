variable "compartment_id" {
  description = "OCID from your tenancy page"
  type        = string
}
variable "region" {
  description = "region where you have OCI tenancy"
  type        = string
  default     = "us-ashburn-1"
}
variable "connection_type" {
  description = "The type of connection to create (e.g. GITHUB, BITBUCKET)"
  type        = string
}
variable "key_management_endpoint" {
  description = "The endpoint to manage operations"
  type        = string
}
variable "key_key_shape_algorithm" {
  description = "The algorithm to manage key versions"
  type        = string
}
variable "key_key_shape_length" {
  description = "The length of the key in bytes"
  type        = number
}
variable "key_protection_mode" {
  description = "The key's protection mode"
  type        = string
}
variable "secret_secret_content_content_type" {
  description = "The content type of the github pat secret"
  type        = string
}
variable "secret_secret_content_content" {
  description = "The base64 encoded content of the github pat secret"
  type        = string
}
variable "repository_mirror_repository_config_repository_url" {
  description = "The url of the external repository"
  type        = string
}
variable "repository_mirror_repository_config_trigger_schedule_schedule_type" {
  type    = string
  default = "DEFAULT"
}