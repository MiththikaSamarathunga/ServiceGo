# iOS Firebase setup (steps)

This document lists the exact steps to register your iOS app in Firebase and wire up `GoogleService-Info.plist` into this Flutter repo.

Bundle ID to register in Firebase
- Use this bundle id when adding the iOS app in Firebase: `com.example.utilityGo`
  - (This is the `PRODUCT_BUNDLE_IDENTIFIER` defined in `ios/Runner.xcodeproj/project.pbxproj`.)

What I can do in this repo
- I added this doc with the bundle id and exact file path where `GoogleService-Info.plist` must go.
- I created the `ios/` platform files earlier (`flutter create --platforms=ios .`).

What you must do in Firebase console (step-by-step)
1. Open Firebase Console: https://console.firebase.google.com
2. Select your Firebase project (or create a new one).
3. Add an iOS app:
   - Click the gear icon → Project settings → "Your apps" → Add app → iOS
   - Enter the iOS bundle ID: `com.example.utilityGo`
   - Optionally set an App nickname (for your reference)
   - Register the app
4. Download `GoogleService-Info.plist` when prompted.

What to do locally after downloading `GoogleService-Info.plist`
1. Place the downloaded file at:
   - `ios/Runner/GoogleService-Info.plist`
2. (On macOS) open the `ios/Runner.xcworkspace` in Xcode and verify:
   - The `GoogleService-Info.plist` file appears in the Runner project and is included in the Runner target (check the File Inspector → Target Membership).
   - Under Runner target → Signing & Capabilities set your development team (so you can run on devices/simulator).
3. If you use Google Sign-In, open `GoogleService-Info.plist` and copy the `REVERSED_CLIENT_ID` value; in Xcode add it under Runner target → Info → URL Types → add new URL type and paste `REVERSED_CLIENT_ID` in the URL Schemes field.

Regenerate `lib/firebase_options.dart` (recommended)
- On your development machine, install FlutterFire CLI if not present:
```bash
flutter pub global activate flutterfire_cli
```
- Run (from project root) and follow prompts to include iOS:
```bash
flutterfire configure
```
- This will generate/update `lib/firebase_options.dart` with correct iOS options.

Enable Firebase services in console
- Authentication → Sign-in method → enable Email/Password and/or Google Sign-In as needed.
- Firestore → Create database (start in test mode for dev), then later tighten rules.
- If supporting web, add authorized domains (e.g., `localhost`) under Authentication → Authorized domains.

Android notes (if not done already)
- If you haven't added Android SHA fingerprints for Google Sign-In, do that in the Firebase app settings (you can get debug SHA using `keytool` or `./gradlew signingReport`).

Build & test
- On macOS (required to run/build iOS binaries):
```bash
flutter clean
flutter pub get
flutter run -d <ios_device_or_simulator>
```
- If you only set this up on Windows, you'll need to copy the repo to a Mac or CI with Xcode to build/run for iOS.

Security and production
- Do NOT keep Firestore rules in permissive `allow read, write: if true` mode in production.
- Add App Store / Play Store OAuth client IDs and enable SHA keys for production signing if using Google Sign-In.

If you want me to do more here in the repo
- I cannot download the `GoogleService-Info.plist` from your Firebase project (requires your Firebase console interaction). But after you download, I can:
  - Add it to `ios/Runner/GoogleService-Info.plist` in the repo for you (if you paste the file or upload it).
  - Re-run `flutterfire configure` instructions and commit the generated `lib/firebase_options.dart` (you must run the CLI locally because it needs your Google account credentials).

If you prefer, I can guide you through each Firebase console click while you do them and then you paste the downloaded `GoogleService-Info.plist` contents here and I will add it to the repo for you.

---
File locations in this repo:
- Put `GoogleService-Info.plist` here: `ios/Runner/GoogleService-Info.plist`
- After running `flutterfire configure` the `lib/firebase_options.dart` file will be updated automatically.

Questions:
- Do you want me to add a placeholder `ios/Runner/GoogleService-Info.plist` now (empty template) so you can replace it later? Or would you like step-by-step guidance while you register the app in Firebase and download the file now?