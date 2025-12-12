# Firebase Web app setup (steps)

This file explains how to register a Web app in Firebase, where to paste the config, and what to configure in the Firebase console.

1) Create / register the Web app in Firebase
- Open Firebase Console: https://console.firebase.google.com and choose your project (or create one).
- Project settings → Your apps → Add app → Web
  - Put a nickname (optional).
  - Register the app.
- After registering Firebase shows you a config object that looks like:

```js
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456",
  measurementId: "G-MEASUREMENT_ID"
};
```

Copy that entire object — you will paste these values into `lib/firebase_options.dart` or let `flutterfire configure` write them for you.

2) Add authorized domains (important for web auth)
- Firebase Console → Authentication → Sign-in method → Authorized domains
- Add `localhost` (and any domain you will serve from) to avoid 400/unauthorized errors during web sign-in.

3) Place the config into this Flutter project
Option A — recommended: use FlutterFire CLI to configure automatically
- Install CLI if needed:
```bash
flutter pub global activate flutterfire_cli
```
- Run (from project root) and follow prompts to include Web:
```bash
flutterfire configure
```
- The CLI will generate/update `lib/firebase_options.dart` with correct `web` settings and optionally update other platform info.

Option B — manual: paste config into `lib/firebase_options.dart`
- Open `lib/firebase_options.dart` and find the `web` FirebaseOptions block.
- Replace placeholders with the values from the `firebaseConfig` object you copied.

Example (fields you must set):
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'PASTE_API_KEY',
  authDomain: 'your-project.firebaseapp.com',
  projectId: 'your-project-id',
  storageBucket: 'your-project.appspot.com',
  messagingSenderId: '123456789',
  appId: '1:123456789:web:abcdef123456',
  measurementId: 'G-MEASUREMENT_ID',
);
```

4) Enable sign-in methods and Firestore
- Authentication → Sign-in method → enable Email/Password and Google (if needed).
- Firestore → Create database → start in test mode for development (then tighten before production).

5) Web hosting / origin
- If you host the web app, add your host domain under Authentication → Authorized domains.

6) Build & run for web
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

7) Debugging web 400 errors
- Open DevTools Network tab and inspect the failed request. The response body often contains a clear Firebase error code like `API_KEY_INVALID` or `EMAIL_EXISTS`.
- Common fixes:
  - `API_KEY_INVALID` / 400 → wrong API key in `firebase_options.dart` (use the exact web key from Firebase console).
  - `origin_not_allowed` or `Unauthorized domain` → add your origin to Authorized domains.

8) After successful setup
- You can remove the demo login in `AuthProvider`.
- Consider using the Firebase Emulator Suite for local testing of Auth/Firestore.

If you want me to do the parts I can here in the repo
- I cannot access your Firebase console to register the web app or download the config. But once you paste the `firebaseConfig` object (the values) here, I can:
  - Edit `lib/firebase_options.dart` to fill the `web` block with the exact values.
  - Commit the change to the repo for you.

If you prefer, run `flutterfire configure` locally (it needs your Google sign-in). I can guide you through that interactively.

Security note
- `apiKey` in Firebase web config is not secret by itself, but be careful with other secrets (service account JSONs). It's common to commit `lib/firebase_options.dart` to repo for client-side apps.

---

When you're ready, paste the web config object (or the individual values) and I will update `lib/firebase_options.dart` for you.