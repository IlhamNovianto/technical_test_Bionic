import java.util.Properties
import java.io.FileInputStream

// ── Load keystore properties ──────────────────────────────────
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yourcompany.technical_test"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // ✅ Fix: gunakan compilerOptions bukan jvmTarget langsung
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.yourcompany.technical_test"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Fix: Kotlin DSL syntax untuk signingConfigs
    signingConfigs {
        create("release") {
            keyAlias      = keystoreProperties["keyAlias"] as String?
            keyPassword   = keystoreProperties["keyPassword"] as String?
            storePassword = keystoreProperties["storePassword"] as String?
            storeFile     = keystoreProperties["storeFile"]?.let { file(it) }
        }
    }

    buildTypes {
        // ✅ Fix: gunakan getByName bukan release langsung
        getByName("release") {
            signingConfig   = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}