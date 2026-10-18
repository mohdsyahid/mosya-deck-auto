# Mosya Deck Auto

A Flutter Android app rebuilt from the UI assets available in the original Mosya Deck APK. The original Flutter source project was not available, so this repository contains a fresh implementation rather than a restored copy.

## Current status

This is an early prototype. It includes:

- A clock-based dashboard with placeholder weather, prayer-time, and football summaries.
- A basic in-app browser.
- Placeholder prayer-time and football pages.
- Playback of the recovered welcome-chime asset on demand.
- Recovered legacy HTML, image, audio, and prayer-zone data under `assets/` for reference.

External data services, real media-session controls, synchronized lyrics, and Android Auto / Android for Cars integration are not implemented yet. The bundled welcome chime has not been verified as a spoken salam recording. The app does not provide video playback while driving.

## Requirements

- Flutter stable with Dart SDK compatible with `pubspec.yaml`.
- Android SDK and an Android device or emulator.

## Run locally

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Build a debug APK for testing:

```sh
flutter build apk --debug
```

A release APK built with the default local debug signing configuration is for sideload testing only. Configure a private release signing key locally before publishing to Google Play; never commit keystores or signing properties.

## Package identity

- Display name: **Mosya Deck Auto**
- Application ID: `com.mosyadeck.autodeck`

## Notes

The app uses the prayer-zone data and UI assets recovered from the previous APK. Confirm rights and applicable service terms for any bundled asset or external data source before distributing a public build.
