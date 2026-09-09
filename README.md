# Connectors

The Connectors mobile app — brand expansion, franchising, and property
matching, talking to the same backend as [connectors.group](https://connectors.group).
Android and iOS, one Flutter codebase.

## Local development

```
flutter pub get
flutter run
```

`flutter analyze` and `flutter test` must both be clean before pushing —
CI (`.github/workflows/build-apk.yml`) fails the build on either.

## Google & Apple sign-in

The code is complete on both sides; it stays switched off until the
credentials below exist. The app hides a provider's button entirely when
its configuration is missing (`OAuthService.googleConfigured` /
`appleAvailable`), so an unconfigured build simply shows email + password
rather than a button that fails.

**How it works.** The app runs the native sign-in sheet and sends only the
provider's ID token to `POST /api/mobile/auth/oauth`. The server verifies
that token against Google's/Apple's own signing keys before trusting any
claim in it — the app never asserts who someone is. If the verified email
already has an account, that's a sign-in. If it doesn't, nothing is created
yet: the server returns a short-lived signed `pendingToken`, the app asks
for the account type and company name (which no provider can supply), and
`POST /api/mobile/auth/oauth/complete` creates the account.

### 1. Google

In [Google Cloud Console](https://console.cloud.google.com/) → APIs &
Services → Credentials, create **three** OAuth client IDs in one project:

| Client type | Needs | Used for |
|---|---|---|
| **Web** | — | The `serverClientId`. On Android the ID token is minted with *this* as its audience |
| **Android** | package name `group.connectors.app` + the signing certificate SHA-1 | Lets the native sheet work on Android |
| **iOS** | bundle ID `group.connectors.app` | Lets the native sheet work on iOS |

The Android SHA-1 must cover every certificate that will sign the app:

```
# Your upload keystore (see "Release signing — Android" below)
keytool -list -v -keystore upload-keystore.jks -alias upload

# Debug builds, if you want sign-in to work when running locally
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

Once the app is on Play, add **Play App Signing's** SHA-1 too (Play Console
→ Setup → App signing) — Google re-signs the upload with its own key, so
without this, sign-in works in testing and fails in production.

### 2. Apple

Requires the Apple Developer account and a Mac for the Xcode step.

1. Apple Developer → Certificates, Identifiers & Profiles → your App ID
   (`group.connectors.app`) → enable **Sign In with Apple**.
2. In Xcode, add the **Sign in with Apple** capability to the Runner target
   (this writes `Runner.entitlements` — it can't be done from Windows).
3. No key or Services ID is needed for the native iOS flow: the app already
   receives an identity token, and the server verifies it against Apple's
   public keys. (A Services ID + key are only needed if Apple sign-in is
   ever added on Android or the web, which uses a redirect flow instead.)

Apple only appears on iOS/macOS builds. That satisfies App Store guideline
4.8, which requires Sign in with Apple wherever Google sign-in is offered.

### 3. Server environment variables

On the website deployment (Vercel) and in `.env.local` for development.
Both accept a comma-separated list, because a token's audience is whichever
client id performed the sign-in:

```
GOOGLE_OAUTH_CLIENT_IDS=<web client id>,<ios client id>
APPLE_OAUTH_CLIENT_IDS=group.connectors.app
```

Leave either unset and that provider's endpoint returns a clean 503 rather
than failing in a confusing way.

### 4. App build-time configuration

The Google client IDs are compiled in with `--dart-define`, so they aren't
committed. `.github/workflows/build-apk.yml` already passes them on every
build, sourced from **repo Variables** (Settings → Secrets and variables →
Actions → *Variables* tab, not *Secrets* — a client ID isn't sensitive, it's
visible in every sign-in request the app makes, but keeping it out of
committed source still means a fork doesn't inherit a working client and
staging/production can use different projects):

```
GOOGLE_SERVER_CLIENT_ID=<web client id>
GOOGLE_IOS_CLIENT_ID=<ios client id>
```

For a local `flutter run`/manual build, pass the same two as `--dart-define`:

```
flutter build appbundle --release \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id> \
  --dart-define=GOOGLE_IOS_CLIENT_ID=<ios client id>
```

iOS additionally needs the reversed iOS client ID as a URL scheme in
`ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array><dict><key>CFBundleURLSchemes</key>
  <array><string>com.googleusercontent.apps.NNNNN-XXXX</string></array>
</dict></array>
```

### What is not built

Phone/SMS sign-in. `PhoneLoginScreen` and `OtpScreen` still exist but
nothing links to them: there's no SMS provider and no phone-auth endpoint,
so the OTP step could never verify a code. Self-service password reset is
also absent — the login screen points people at support, and an admin
resets it from the website.

## App icon

Drop a 1024x1024 PNG at `assets/icon/app_icon.png`, then:

```
dart run flutter_launcher_icons
```

That regenerates every launcher/app-store icon size for both platforms
(including Android's adaptive icon foreground/background) from that one
file — see `assets/icon/README.md` and the `flutter_launcher_icons:`
block in `pubspec.yaml` for the config.

## Release signing — Android

Play Store needs every update signed with the *same* key forever — lose
it, and you can never publish an update to this listing again under this
identity. Generate it once, back it up somewhere durable (not just this
machine), and never commit it.

1. Generate the upload key (needs a JDK — `keytool` ships with it):

   ```
   keytool -genkey -v -keystore connectors-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   Keep the resulting `.jks` file and the passwords you set somewhere safe
   (a password manager, not just this repo's folder).

2. For a **local** release build, copy `android/key.properties.example` to
   `android/key.properties` (already gitignored) and fill in the real
   values, including the absolute path to the `.jks` file. Then:

   ```
   flutter build appbundle --release
   ```

   The `.aab` is what Play Console actually wants (Google has required App
   Bundles over raw APKs since 2021) — it's at
   `build/app/outputs/bundle/release/app-release.aab`.

3. For **CI** to produce a signed build, add these under this repo's
   Settings → Secrets and variables → Actions:

   - `ANDROID_KEYSTORE_BASE64` — the `.jks` file, base64-encoded
     (`base64 -w0 connectors-upload-key.jks` on macOS/Linux, or on Windows:
     `[Convert]::ToBase64String([IO.File]::ReadAllBytes("connectors-upload-key.jks")) | Set-Clipboard`
     in PowerShell).
   - `ANDROID_KEY_ALIAS` — `upload`, if you used the command above.
   - `ANDROID_KEY_PASSWORD` / `ANDROID_STORE_PASSWORD` — the passwords from
     step 1.

   Without these secrets, CI still builds — just signed with Flutter's
   debug key, which is fine for smoke-testing but Play Console will reject
   it on upload.

## Release signing — iOS

There's no Mac in this project's normal dev loop, so iOS builds and
signing have to happen somewhere that has one:

- **A Mac you have access to** — open `ios/Runner.xcworkspace` in Xcode,
  sign in with the Apple ID under your Apple Developer Program
  membership, let Xcode manage the signing certificate/provisioning
  profile automatically, then Product → Archive → Distribute App.
- **CI with a macOS runner** — GitHub Actions has `runs-on: macos-latest`
  runners that can run `flutter build ipa`. Signing still needs your
  Apple Developer certificate and a provisioning profile available to
  that runner (via `fastlane match`, or by exporting and re-encoding them
  as secrets the same way the Android keystore is handled above). This
  is more setup than Android's — worth doing once there's a first
  TestFlight build to actually ship.

Either way, you'll need, from your Apple Developer account:
a Distribution certificate, an App Store provisioning profile for
`group.connectors.app`, and the app registered in App Store Connect.

## Store submission checklist

- [x] Privacy policy is live at <https://connectors.group/privacy> —
      both stores hard-require this URL before they'll even let you fill
      in the rest of the listing.
- [ ] App icon (see above).
- [ ] Screenshots — each store wants a few per required device size
      (Play Store: phone, at minimum; App Store: 6.7" and 6.5" iPhone
      sizes, at minimum). Easiest path: run a release build on a real
      device or emulator/simulator and capture the actual screens.
- [ ] Store listing copy — name, short/full description, category
      (Business), keywords (App Store only). The privacy page's opening
      paragraph and `site.description` in the website repo are a
      reasonable starting point for tone.
- [ ] Play Console's **Data safety** section and App Store Connect's
      **App Privacy** ("nutrition label") — both ask what data the app
      collects; answer from `/privacy`'s "What we collect" section, since
      that's the authoritative, accurate list.
- [ ] Content rating questionnaire (Play Console) / age rating (App Store
      Connect) — this is a B2B business app with no user-generated public
      content, gambling, or mature themes, so the lowest tier applies.
- [ ] Support URL / contact — `mailto:info@connectors.group` or a
      `/contact` page link works for both.
- [ ] First submission: Play Store's **Internal testing** track and
      App Store Connect's **TestFlight** both let you install and check a
      real signed build before it goes anywhere near public review —
      worth doing before hitting submit for real review either place.
- [ ] Once each listing exists (even pre-approval, the URLs are live
      immediately), update `appLinks.ios` / `appLinks.android` in the
      website repo's `src/lib/site.ts` — they're still `"#"` placeholders
      feeding the site's own "Get the app" buttons.
