# secret-mirror

This directory contains mappings between friendly secret names and Bitwarden item IDs.

## Files

- **`items`**: Maps secret names to Bitwarden item UUIDs
  - Format: `<name> <bitwarden-item-uuid>`
  - Example: `mail-password 0f026cb5-c8cc-4ee9-8e66-53e7444f6bfe`
  - These UUIDs are NOT secrets - they're public identifiers
  - Actual secrets are protected by Bitwarden's encryption

## Usage

The `secret-read` and `secret-sync` scripts use this mapping to:
1. Look up the Bitwarden item ID for a friendly name
2. Fetch the actual secret from Bitwarden (requires authentication)
3. Mirror secrets to local files in `~/.local/share/secret-mirror/secrets/`

## Security

- **`items`** is tracked in git (safe to share)
- **`secrets/`** directory is NOT tracked (contains actual secrets)
- Secrets are only accessible when Bitwarden vault is unlocked

## Adding a new secret

1. Store the secret in Bitwarden (Login item or Secure Note)
2. Get the item ID: `bw list items | jq -r '.[] | select(.name=="YourItemName") | .id'`
3. Add mapping to `items`: `echo "your-secret-name <item-id>" >> items`
4. Run `secret-sync` to fetch the secret locally
