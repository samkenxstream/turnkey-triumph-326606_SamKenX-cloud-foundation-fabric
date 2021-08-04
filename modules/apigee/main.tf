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

locals {
  env_envgroup_pairs = flatten([
    for eg_name, eg in var.apigee_envgroups: [
      for e in eg.environments : {
        envgroup   = eg_name
        env = e
      }
    ]
  ])
}

resource "google_apigee_organization" "apigee_org" {
  project_id         = var.project_id
  analytics_region   = var.analytics_region
  display_name       = var.display_name
  description        = var.description
  runtime_type       = var.runtime_type
  authorized_network = var.peering_network
}

resource "google_apigee_environment" "apigee_env" {
  for_each = toset(var.apigee_environments)
  org_id   = google_apigee_organization.apigee_org.id
  name     = each.key
}

resource "google_apigee_envgroup" "apigee_envgroup" {
  for_each  = var.apigee_envgroups
  org_id    = google_apigee_organization.apigee_org.id
  name      = each.key
  hostnames = each.value.hostnames
}

resource "google_apigee_envgroup_attachment" "env_to_envgroup_attachment" {
  for_each    = { for pair in local.env_envgroup_pairs : "${pair.envgroup}-${pair.env}" => pair }
  envgroup_id = google_apigee_envgroup.apigee_envgroup[each.value.envgroup].id
  environment = google_apigee_environment.apigee_env[each.value.env].name
}

resource "google_compute_global_address" "apigee_peering_range" {
  count         = var.peering_range == null ? 0 : 1
  project       = var.project_id
  name          = "${var.project_id}-apigee-peering"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", var.peering_range)[0]
  prefix_length = split("/", var.peering_range)[1]
  network       = var.peering_network
}

resource "google_service_networking_connection" "apigee_vpc_connection" {
  count                   = var.peering_network == null ? 0 : 1
  network                 = "projects/${var.project_id}/global/networks/${var.peering_network}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_peering_range.0.name]
}
