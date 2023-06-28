# Define AWS accounts / permission sets / accounts assignments
locals {
  accounts = {
    bubletea-master = {
      aws_account_id = "999999999999"
    }
    bubletea-audit = {
      aws_account_id = "888888888888"
    }
    bubletea-mgmt = {
      aws_account_id = "111111111111"
    }
    bubletea-nonprod = {
      aws_account_id = "222222222222"
    }
    bubletea-prod = {
      aws_account_id = "333333333333"
    }
  }
  permission_sets = {
    administrator_access = {
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      session_duration = "PT1H"
    },
    cloudtrail_read_only = {
      description      = "Cloudtrail Read Only Access",
      managed_policies = ["arn:aws:iam::aws:policy/AWSCloudTrailReadOnlyAccess"]
      session_duration = "PT1H"
    },
    s3_read_only_access = {
      description      = "Read Only Access to S3 Buckets.",
      inline_policy    = data.aws_iam_policy_document.s3_read_only_access.json
      session_duration = "PT1H"
    },
    read_only_nonprod = {
      managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      inline_policy    = data.aws_iam_policy_document.read_only_nonprod.json
      session_duration = "PT1H"
      tags = {
        purpose = "devops-readonly"
      }
    },
    sso_admin_access = {
      session_duration = "PT1H",
      managed_policies = [
        "arn:aws:iam::aws:policy/AWSCloudShellFullAccess",
        "arn:aws:iam::aws:policy/AWSSupportAccess",
        "arn:aws:iam::aws:policy/AWSSSOMemberAccountAdministrator"
      ]
    }
  }
  account_assignments = [
    {
      principal_name = "Admin"
      principal_type = "GROUP"
      permission_set = "AdministratorAccess"
      accounts = [
        "bubletea-audit",
        "bubletea-mgmt",
        "bubletea-nonprod",
        "bubletea-prod",
      ]
    },
    {
      principal_name = "cloudtrail_read_only"
      principal_type = "GROUP"
      permission_set = "cloudtrail_read_only"
      accounts = [
        "bubletea-master"
      ]
    },
    {
      principal_name = "user@example.com"
      principal_type = "USER"
      permission_set = "s3_read_only_access"
      accounts = [
        "bubletea-prod"
      ]
    },
    {
      principal_name = "read_only_nonprod"
      principal_type = "GROUP"
      permission_set = "read-only_nonprod"
      accounts = [
        "bubletea-nonprod"
      ]
    },
    {
      principal_name = "sso_admin_access"
      principal_type = "GROUP"
      permission_set = "sso_admin_access"
      accounts = [
        "bubletea-master"
      ]
    }
  ]
}

# Inline Policies
data "aws_iam_policy_document" "s3_read_only_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::DOC-EXAMPLE-BUCKET1/",
      "arn:aws:s3:::DOC-EXAMPLE-BUCKET1/*"
    ]
  }
}

data "aws_iam_policy_document" "read_only_nonprod" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/MyTable"
    ]
  }
}

module "identity_center" {
  source = "git::https://github.com/DNXLabs/terraform-aws-identity-center.git?ref=0.1.0"

  accounts            = local.accounts
  permission_sets     = local.permission_sets
  account_assignments = local.account_assignments
}