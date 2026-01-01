CI README

This repo includes an example GitHub Actions workflow that builds a signed AAB using secrets.

Required GitHub Secrets (set in repo Settings → Secrets):
- `RELEASE_KEYSTORE_BASE64`: Base64-encoded contents of `vinayagar-release-key.jks`
- `RELEASE_KEYSTORE_PASSWORD`: Keystore store password
- `RELEASE_KEY_PASSWORD`: Key password
- `RELEASE_KEY_ALIAS`: Key alias (e.g., vinayagar)

How to produce base64 keystore locally:
```bash
base64 -w 0 android/app/vinayagar-release-key.jks > keystore.base64
# Copy the contents of keystore.base64 into the GitHub secret RELEASE_KEYSTORE_BASE64
```

Notes:
- Keep the keystore secret; do NOT commit `vinayagar-release-key.jks` or `android/key.properties` to the repo.
- The workflow will create `android/key.properties` at runtime using secrets, then build the AAB.
