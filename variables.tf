# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}
variable "username" {
  description = "The username of resource to be created."
}
variable "password" {
  description = "The password for resource to be created."
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default     = {
    environment = "codelab"
    name ="udacityproject1"
  }
}

variable "application_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
  default     = "ChangeMe123!"
  sensitive   = true
}
variable "instance_count" {
  description = "Number of virtual machines needed for scaleset"
  default     = 2
}
