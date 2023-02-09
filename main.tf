resource "aws_ssoadmin_permission_set" "default" {
  for_each = var.permission_sets

  name             = each.key
  description      = lookup(each.value, "description", null)
  instance_arn     = local.ssoadmin_instance_arn
  relay_state      = lookup(each.value, "relay_state", null)
  session_duration = lookup(each.value, "session_duration", null)

  tags = lookup(each.value, "tags", {})
}

resource "aws_ssoadmin_permission_set_inline_policy" "default" {
  for_each = { for ps_name, ps_attrs in var.permission_sets : ps_name => ps_attrs if can(ps_attrs.inline_policy) }

  inline_policy      = each.value.inline_policy
  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.key].arn
}

resource "aws_ssoadmin_managed_policy_attachment" "default" {
  for_each = { for ps in local.ps_policy_maps : "${ps.ps_name}.${ps.policy_arn}" => ps }

  instance_arn       = local.ssoadmin_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.value.ps_name].arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "default" {
  for_each = { for ps in local.customer_ps_policy_maps : "${ps.ps_name}.${ps.policy_name}" => ps }

  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.value.ps_name].arn

  customer_managed_policy_reference {
    name = each.value.policy_name
    path = "/"
  }
}

resource "aws_ssoadmin_account_assignment" "default" {
  for_each = { for assignment in local.account_assignments : "${assignment.principal_name}.${assignment.permission_set.name}.${assignment.account_id}" => assignment }

  instance_arn       = each.value.permission_set.instance_arn
  permission_set_arn = each.value.permission_set.arn
  principal_id       = each.value.principal_type == "GROUP" ? data.aws_identitystore_group.default[each.value.principal_name].id : data.aws_identitystore_user.default[each.value.principal_name].id
  principal_type     = each.value.principal_type

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}