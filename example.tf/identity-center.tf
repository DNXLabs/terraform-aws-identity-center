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
    AdministratorAccess = {
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      session_duration = "PT1H"
    },
    Cloudtrail-Read-Only = {
      description      = "Cloudtrail Read Only Access",
      managed_policies = ["arn:aws:iam::aws:policy/AWSCloudTrailReadOnlyAccess"]
      session_duration = "PT1H"
    },
    S3-Read-Only-Access = {
      description      = "Read Only Access to S3 Buckets.",
      inline_policy    = data.aws_iam_policy_document.S3-Read-Only-Access.json
      session_duration = "PT1H"
    },
    ReadOnly-Nonprod = {
      managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      inline_policy    = data.aws_iam_policy_document.ReadOnly-Nonprod.json
      session_duration = "PT1H"
      tags = {
        purpose = "devops-readonly"
      }
    },
    SSO-Admin-Access = {
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
      principal_name = "Cloudtrail-Read-Only"
      principal_type = "GROUP"
      permission_set = "Cloudtrail-Read-Only"
      accounts = [
        "bubletea-master"
      ]
    },
    {
      principal_name = "user@example.com"
      principal_type = "USER"
      permission_set = "S3-Read-Only-Access"
      accounts = [
        "bubletea-prod"
      ]
    },
    {
      principal_name = "Read-Only-Nonprod"
      principal_type = "GROUP"
      permission_set = "ReadOnly-Nonprod"
      accounts = [
        "bubletea-nonprod"
      ]
    },
    {
      principal_name = "SSO-Admin-Access"
      principal_type = "GROUP"
      permission_set = "SSO-Admin-Access"
      accounts = [
        "bubletea-master"
      ]
    }
  ]
}

# Inline Policies
data "aws_iam_policy_document" "S3-Read-Only-Access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ReadOnly-Nonprod" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"
    actions = [
      "airflow:ListTagsForResource",
      "airflow:CreateWebLoginToken",
      "airflow:GetEnvironment",
      "airflow:ListEnvironments"
    ]
    resources = ["*"]
  }
}

module "identity_center" {
  source = "git::https://github.com/DNXLabs/terraform-aws-identity-center.git?ref=0.1.0"

  permission_sets     = local.workspace.sso.permission_sets
  accounts            = local.workspace.sso.accounts
  account_assignments = local.workspace.sso.account_assignments
}