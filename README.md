# terraform-aws-identity-center

[![Lint Status](https://github.com/DNXLabs/terraform-aws-identity-center/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-identity-center/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-identity-center)](https://github.com/DNXLabs/terraform-aws-identity-center/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_assignments | List of maps containing mapping between user/group, permission set and assigned accounts list. | <pre>list(object({<br>    principal_name = string,<br>    principal_type = string,<br>    permission_set = string,<br>    accounts       = list(string)<br>  }))</pre> | n/a | yes |
| accounts | List of the AWS accounts | `any` | n/a | yes |
| permission\_sets | Map of maps containing Permission Set names as keys. | `any` | n/a | yes |

## Outputs

No output.

<!--- END_TF_DOCS --->