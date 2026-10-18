import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningProperties = Properties().apply {
    listOf(
        rootProject.file("key.properties"),
        rootProject.file("../notes/signing_credentials.properties"),
    ).filter { it.isFile }.forEach { propertiesFile ->
        propertiesFile.inputStream().use { load(it) }
    }
}

val releaseRequested = gradle.startParameter.taskNames.any { taskName ->
    val task = taskName.substringAfterLast(':')
    task.contains("Release", ignoreCase = true) || task.equals("build", ignoreCase = true)
}
if (releaseRequested) {
    val required = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    require(required.all { !releaseSigningProperties.getProperty(it).isNullOrBlank() }) {
        "Missing Android release signing fields in android/key.properties or notes/signing_credentials.properties"
    }
    require(file(releaseSigningProperties.getProperty("storeFile")).isFile) {
        "Android release keystore file does not exist"
    }
}

android {
    namespace = "org.firstapp.rafalsiuta.fitcalc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "org.firstapp.rafalsiuta.fitcalc"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = releaseSigningProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = releaseSigningProperties.getProperty("storePassword")
            keyAlias = releaseSigningProperties.getProperty("keyAlias")
            keyPassword = releaseSigningProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
