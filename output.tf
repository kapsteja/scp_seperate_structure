output "deny_scp_ids" {
  value = { for k, v in aws_organizations_policy.deny_scp : k => v.id }
}

output "deny_scp_names" {
  value = [for k, v in aws_organizations_policy.deny_scp : v.name]
}

output "other_scp_ids" {
  value = { for k, v in aws_organizations_policy.other_scp : k => v.id }
}

output "other_scp_names" {
  value = [for k, v in aws_organizations_policy.other_scp : v.name]
}
