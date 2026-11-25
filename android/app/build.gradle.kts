plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.fares.animals"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.fares.animals"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Pinned signing key: the project-local copy of the debug
    // keystore (android/debug.keystore, SHA-256 3F:85:02:BB:…:13:1B:85 —
    // the fingerprint that signed v1.0.1).
    // Builds must never resolve the keystore from the builder's
    // home directory again: that keystore was recreated once
    // (25/11) and silently changed the fingerprint (2D:7D:…:4F:92 → 3F:85:…:1B:85),
    // so v1.0.1 cannot update over the v1.0.0 debug APK in place.
    // The keystore file itself is excluded from git (see .gitignore)
    // — the repo is public. On Codemagic it is uploaded once as the
    // signing identity `fares-animals-debug-keystore` and copied to
    // android/debug.keystore before the build (see codemagic.yaml).
    signingConfigs {
        create("pinnedDebug") {
            storeFile = rootProject.file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // Signed with the pinned keystore above, so every
            // future build keeps the same SHA-256 fingerprint.
            signingConfig = signingConfigs.getByName("pinnedDebug")
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
