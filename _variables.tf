variable "accounts" {
  description = "List of the AWS accounts"
}

variable "permission_sets" {
  description = "Map of maps containing Permission Set names as keys."
}

variable "account_assignments" {
  description = "List of maps containing mapping between user/group, permission set and assigned accounts list."
  type = list(object({
    principal_name = string,
    principal_type = string,
    permission_set = string,
    accounts       = list(string)
  }))
}