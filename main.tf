terraform {
  required_providers {
    gitlab = "1.2.0"
  }
}

provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.base_url
  insecure = true
}

# Creates a cohort of Gitlab Users onto this Gitlab Instance
resource "gitlab_user" "this" {
  for_each = var.users

  name              = each.value.username
  username          = each.value.username
  password          = each.value.password
  email             = each.value.email
  is_admin          = false
  projects_limit    = 100
  can_create_group  = true
  is_external       = false
  skip_confirmation = true
}

# Creates a cohort of Gitlab Groups onto this Gitlab Instance
resource "gitlab_group" "this" {
  for_each = var.groups

  name        = each.value.group_name
  path        = each.value.group_name
  description = each.value.group_description
}

# Establishes membership of the Gitlab Users with Gitlab Groups
resource "gitlab_group_membership" "this" {
  for_each = local.memberships

  group_id     = lookup(gitlab_group.this[format("%s", each.value.group)], "id", "0")
  user_id      = lookup(gitlab_user.this[format("%s", each.value.email)], "id", "0")
  access_level = "guest"
}
