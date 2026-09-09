// Imported rather than written as `java.util.Properties` / `java.io.FileInputStream`
// inline: in a module build script the Android plugin applies JavaBasePlugin,
// which puts a `java` extension accessor (JavaPluginExtension) in scope. That
// shadows the `java.*` package root, so a fully-qualified `java.util.Properties()`
// here fails to compile with "Unresolved reference 'util'" — unlike in
// settings.gradle.kts, which has no such accessor and can qualify it inline.
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Read once at configuration time. Absent on any machine that hasn't been set
// up for release signing (and in CI until the ANDROID_KEYSTORE_* secrets are
// added) — see android/key.properties.example and README.md's release-signing
// notes. Everything below falls back to the debug key when it's missing, so
// local `flutter run`/debug builds keep working; a release build signed with
// the debug key is only good for smoke-testing, never for Play Store upload.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
val keystoreProperties = Properties().apply {
    if (hasReleaseKeystore) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}

android {
    namespace = "group.connectors.app"
    // Hardcoded rather than flutter.compileSdkVersion: that default (36)
    // hasn't caught up to flutter_secure_storage 11.x's AAR, which declares
    // a minCompileSdk of 37 and fails CheckAarMetadataWorkAction otherwise.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "group.connectors.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Only created when there's a real keystore to point it at — an
        // empty, unusable "release" config would otherwise sit in the build
        // looking configured.
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
