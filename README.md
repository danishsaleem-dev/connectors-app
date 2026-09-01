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
