variable "deny_scp_files" {
  description = "List of Deny SCP JSON files from Deny/policies/"
  type        = list(string)
  default     = []
}

variable "deny_attachments" {
  description = "Map of Deny policy names to target IDs"
  type        = map(list(string))
  default     = {}
}

variable "other_scp_files" {
  description = "List of Other SCP JSON files from others/policies/"
  type        = list(string)
  default     = []
}

variable "other_attachments" {
  description = "Map of Other policy names to target IDs"
  type        = map(list(string))
  default     = {}
}

variable "common_tags" {
  description = "Common tags for all policies"
  type        = map(string)
  default = {
    Terraform = "true"
    ManagedBy = "Terraform"
  }
}