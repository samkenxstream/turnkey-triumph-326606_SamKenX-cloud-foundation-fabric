/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "Project ID to host this Apigee organization (will also become the Apigee Org name)."
  type        = string
}

variable "analytics_region" {
  description = "Analytics Region for the Apgiee Organization (immutable). See https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli."
  type = string
  default = "us-central1"
}

variable "display_name" {
  description = "Display Name of the Apigee Organization."
  type = string
  default = null
}

variable "description" {
  description = "Description of the Apigee Organization."
  type = string
  default = "Apigee Organization created by tf module"
}

variable "runtime_type" {
  type    = string

  validation {
    condition     = contains(["CLOUD", "HYBRID"], var.runtime_type)
    error_message = "Allowed values for runtime_type \"CLOUD\" or \"HYBRID\"."
  }
}

variable "peering_network" {
  description = "VPC Network used for peering Apigee (Used in Apigee X only)."
  type = string
  default = null

  # validation {
  #   condition = var.runtime_type == "CLOUD" ? var.peering_vpc != null : true
  #   error_message = "A peering_vpc must be provided for Apigee Organizations of runtime_type \"CLOUD\"."
  # }
}

variable "peering_range" {
  description = "RFC1919 CIDR range used for peering the Apigee tennant project. Min size for trial is /22 min size for PAID is /20"
  type = string
  default = null
}

variable "apigee_environments" {
  description = "Apigee Environment Names."
  type = list(string)
  default = []
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    environments      = list(string)
    hostnames         = list(string)
  }))
  default = {}
}
