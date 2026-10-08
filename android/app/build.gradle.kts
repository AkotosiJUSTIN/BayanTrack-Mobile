import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun signingValue(environmentName: String, propertyName: String): String? =
    System.getenv(environmentName) ?: keystoreProperties.getProperty(propertyName)

android {
    namespace = "com.example.bayantrack_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.bayantrack_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = signingValue("ANDROID_KEYSTORE_PATH", "storeFile")?.let { file(it) }
            storePassword = signingValue("ANDROID_KEYSTORE_PASSWORD", "storePassword")
            keyAlias = signingValue("ANDROID_KEY_ALIAS", "keyAlias")
            keyPassword = signingValue("ANDROID_KEY_PASSWORD", "keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

gradle.taskGraph.whenReady {
    if (allTasks.any { it.project == project && it.name.endsWith("Release") }) {
        val signing = android.signingConfigs.getByName("release")
        check(
            signing.storeFile?.isFile == true &&
                !signing.storePassword.isNullOrBlank() &&
                !signing.keyAlias.isNullOrBlank() &&
                !signing.keyPassword.isNullOrBlank()
        ) {
            "Release signing requires a keystore and all signing credentials. " +
                "Configure android/key.properties or the ANDROID_KEYSTORE_* environment variables."
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}

// Apply Google Services plugin to process google-services.json into Android resources
apply(plugin = "com.google.gms.google-services")
