# GitHub Secrets Setup for Release Signing

## Setup Instructions

1. Go to your GitHub repository
2. Navigate to: Settings > Secrets and variables > Actions
3. Add the following secrets:

### Required Secrets:

**KEYSTORE_BASE64**
- Description: Base64 encoded keystore file
- Value: Copy from `keystore-base64.txt` (entire content - this file is gitignored)

**KEYSTORE_PASSWORD**
- Description: Keystore password
- Value: [Ask team lead for the password]

**KEY_ALIAS**
- Description: Key alias name
- Value: `upload`

**KEY_PASSWORD**
- Description: Key password
- Value: [Ask team lead for the password]

## Files Created:
- `android/app/upload-keystore.jks` - The keystore file (gitignored)
- `android/key.properties` - Keystore properties (gitignored)
- `keystore-base64.txt` - Base64 encoded keystore (gitignored)

## Important Notes:
- **NEVER commit keystore files or passwords to git**
- The keystore is valid for 10,000 days (~27 years)
- Keep backups of the keystore file in a secure location
- Losing the keystore means you cannot update the app without users uninstalling first

## Keystore Info:
- Key Algorithm: RSA 2048-bit
- Validity: 10,000 days
- Organization: LSP Digital
- Email: lsptdti@lspdigital.id
