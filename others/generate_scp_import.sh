#!/bin/bash
set -euo pipefail

echo "=== Generating Other SCPs (policies NOT starting with 'Deny') ==="

# Sanity checks
if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI not found in PATH. Install and configure AWS CLI with proper credentials." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not found in PATH. Install jq to parse JSON outputs." >&2
  exit 1
fi

# Output files
POLICIES_DIR="policies"
IMPORTS_FILE="imports.sh"
TFVARS_FILE="others.tfvars"

# Initialize import script
echo "#!/bin/bash" > "$IMPORTS_FILE"
echo "set -euo pipefail" >> "$IMPORTS_FILE"
echo "# Auto-generated Terraform import commands for Other policies" >> "$IMPORTS_FILE"
echo "" >> "$IMPORTS_FILE"

# Initialize tfvars file
echo "# Auto-generated variables for Other policies" > "$TFVARS_FILE"
echo "other_scp_files = [" >> "$TFVARS_FILE"

# Temp file for attachments
ATTACH_TMP="${TFVARS_FILE}.attachments.tmp"
> "$ATTACH_TMP"

# Ensure policies directory exists
mkdir -p "$POLICIES_DIR"

# Step 1: List all SCPs
policies=$(aws organizations list-policies --filter SERVICE_CONTROL_POLICY \
  --query 'Policies[*].Id' --output text | tr -d '\r')

for pid in $policies; do
  # Get SCP name
  raw_name=$(aws organizations describe-policy --policy-id "$pid" \
    --query 'Policy.PolicySummary.Name' --output text | tr -d '\r')

  # Only process policies NOT starting with "Deny"
  if [[ "$raw_name" =~ ^Deny ]]; then
    continue
  fi

  # (User requested) No longer skipping AWS-managed or guardrail-named policies;
  # all policies not starting with 'Deny' will be processed.

  safe_name=$(echo "$raw_name" | tr -d '[:space:]' | tr '/:' '_' | tr -cd '[:alnum:]_-')

  echo ">>> Processing OTHER policy: $raw_name (safe filename: $safe_name.json)"

  # SCP import command
  echo "terraform import 'aws_organizations_policy.other_scp[\"${safe_name}.json\"]' $pid" >> "$IMPORTS_FILE"

  # Add to tfvars
  echo "  \"${safe_name}.json\"," >> "$TFVARS_FILE"

  # Export SCP JSON
  aws organizations describe-policy --policy-id "$pid" \
    --query 'Policy.Content' --output text > "${POLICIES_DIR}/${safe_name}.json"

  # Get attachments
  targets=$(aws organizations list-targets-for-policy --policy-id "$pid" \
    --output json | jq -r '.Targets[].TargetId' | tr -d '\r')

  echo ">>> Attachments for $safe_name: [$targets]"

  echo "  \"${safe_name}\" = [" >> "$ATTACH_TMP"
  if [ -n "$targets" ]; then
    for tid in $targets; do
      tid_clean=$(echo "$tid" | tr -d '\r')
      # Terraform import for attachments expects format: policy-id:target-id
      echo "terraform import 'aws_organizations_policy_attachment.other_attach[\"${safe_name}_${tid_clean}\"]' ${pid}:${tid_clean}" >> "$IMPORTS_FILE"
      echo "    \"${tid_clean}\"," >> "$ATTACH_TMP"
    done
  else
    echo "    # No attachments found" >> "$ATTACH_TMP"
  fi
  echo "  ]" >> "$ATTACH_TMP"
done

# Close tfvars array
echo "]" >> "$TFVARS_FILE"
echo "" >> "$TFVARS_FILE"
echo "# Auto-generated attachments map" >> "$TFVARS_FILE"
echo "other_attachments = {" >> "$TFVARS_FILE"
cat "$ATTACH_TMP" >> "$TFVARS_FILE"
echo "}" >> "$TFVARS_FILE"
rm -f "$ATTACH_TMP"

chmod +x "$IMPORTS_FILE" || true

echo ""
echo "=== Done! Other policies generated ==="
echo "Files created:"
echo "  - policies/ (policy JSON files)"
echo "  - imports.sh (import commands)"
echo "  - others.tfvars (variables)"
echo ""
echo "Next step:"
echo "  cd .. && terraform apply -var-file=others/others.tfvars"
