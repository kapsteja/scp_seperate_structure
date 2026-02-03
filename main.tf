# Central Terraform configuration for managing both Deny and Other SCPs
# This file manages policies from both Deny/ and others/ directories

# ============= DENY POLICIES =============
# Load Deny SCP JSON files
data "local_file" "deny_scp" {
  for_each = toset(var.deny_scp_files)
  filename = "${path.module}/Deny/policies/${each.value}"
}

# Create Deny SCPs
resource "aws_organizations_policy" "deny_scp" {
  for_each = data.local_file.deny_scp

  name        = replace(each.key, ".json", "")
  description = "Managed Deny SCP: ${each.key}"
  lifecycle {
    ignore_changes = [description, name, tags, tags_all]
  }
  type    = "SERVICE_CONTROL_POLICY"
  content = each.value.content
  tags    = merge(var.common_tags, { Category = "Deny" })
}

# Attach Deny policies
resource "aws_organizations_policy_attachment" "deny_attach" {
  for_each = {
    for combo in flatten([
      for policy_name, target_ids in var.deny_attachments : [
        for target_id in target_ids : {
          policy = policy_name
          target = target_id
        }
      ]
    ]) : "${combo.policy}_${combo.target}" => combo
  }

  policy_id = aws_organizations_policy.deny_scp[each.value.policy].id
  target_id = each.value.target
}

# ============= OTHER POLICIES =============
# Load Other SCP JSON files
data "local_file" "other_scp" {
  for_each = toset(var.other_scp_files)
  filename = "${path.module}/others/policies/${each.value}"
}

# Create Other SCPs
resource "aws_organizations_policy" "other_scp" {
  for_each = data.local_file.other_scp

  name        = replace(each.key, ".json", "")
  description = "Managed Other SCP: ${each.key}"
  lifecycle {
    ignore_changes = [description, name, tags, tags_all]
  }
  type    = "SERVICE_CONTROL_POLICY"
  content = each.value.content
  tags    = merge(var.common_tags, { Category = "Other" })
}

# Attach Other policies
resource "aws_organizations_policy_attachment" "other_attach" {
  for_each = {
    for combo in flatten([
      for policy_name, target_ids in var.other_attachments : [
        for target_id in target_ids : {
          policy = policy_name
          target = target_id
        }
      ]
    ]) : "${combo.policy}_${combo.target}" => combo
  }

  policy_id = aws_organizations_policy.other_scp[each.value.policy].id
  target_id = each.value.target
}