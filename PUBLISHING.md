Play Store Publishing Checklist

1) Prepare and secure your release keystore
- Keep `vinayagar-release-key.jks` in a safe location (do NOT commit it to git).
- Remove `android/key.properties` from the repo and store signing secrets in CI or a secure vault.

2) Increase version (pubspec.yaml)
- Update `version:` in `pubspec.yaml` (format `x.y.z+buildNumber`).
- Ensure `versionCode` and `versionName` align (Flutter uses `pubspec.yaml` version to set these).

3) Build the AAB (recommended)
```bash
# Build app bundle for Play Store
flutter clean
flutter pub get
flutter build appbundle --release
# The AAB will be at:
# build/app/outputs/bundle/release/app-release.aab
```

4) Get the app signing certificate fingerprint (SHA-256)
```bash
# If using your release keystore
keytool -list -v -keystore /path/to/vinayagar-release-key.jks -alias vinayagar
# If using Play App Signing and you don't have the release key, use the upload key instead
```

5) Create the Play Console app
- Sign in to Google Play Console
- Create a new app, fill in app details (title, default language, contact details, privacy policy URL)
- Upload store listing assets (icon, screenshots, description)

6) Upload internal test AAB
- In Play Console → Release → Testing → Internal testing → Create new release
- Upload `app-release.aab`
- Review and start internal test

7) Promote to open testing / production
- Once tested, promote the internal test release to open testing or production

8) Monitor
- Monitor crash reports, ANRs, and user feedback in the Play Console

Security notes
- Never commit keystores, passwords, or `key.properties` containing secrets to the repository.
- Use CI secrets to inject `key.properties` at build time, or configure signing in Gradle using environment variables.

If you want, I can:
- Generate the AAB here (I can run `flutter build appbundle --release`) and prepare the SHA-256 fingerprint command output.
- Create Play Console store listing drafts (I can prepare the text and assets for you to copy/paste).