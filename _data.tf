data "aws_ssoadmin_instances" "default" {}

data "aws_identitystore_group" "default" {
  for_each          = toset(local.groups)
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
}

data "aws_identitystore_user" "default" {
  for_each          = toset(local.users)
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value
    }
  }
}