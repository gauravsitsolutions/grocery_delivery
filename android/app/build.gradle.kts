plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.samrudhi_delivery_agent_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }


    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.samrudhi_delivery_agent_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        outputs.all {
            val output = this as? com.android.build.gradle.api.ApkVariantOutput
            val type = buildType.name
            output?.outputFileName = if (type == "release") {
                "Samruddha-Kirana-Delivery-Agent.apk"
            } else {
                "Samruddha-Kirana-Delivery-Agent-$type.apk"
            }
        }
    }
}

tasks.register("copyCustomApk") {
    doLast {
        val buildDir = project.layout.buildDirectory.asFile.get()
        val flutterApkDir = File(buildDir, "outputs/flutter-apk")
        val apkOutputDir = File(buildDir, "outputs/apk")

        flutterApkDir.mkdirs()

        // Copy from apkOutputDir variants if available
        listOf("release", "debug").forEach { variant ->
            val variantDir = File(apkOutputDir, variant)
            if (variantDir.exists()) {
                variantDir.listFiles()?.forEach { file ->
                    if (file.extension == "apk") {
                        file.copyTo(File(flutterApkDir, "Samruddha-Kirana-Delivery-Agent.apk"), overwrite = true)
                        file.copyTo(File(flutterApkDir, "Samruddha-Kirana-Delivery-Agent-$variant.apk"), overwrite = true)
                    }
                }
            }
        }

        // Copy from flutterApkDir if standard app-<mode>.apk exists
        flutterApkDir.listFiles()?.forEach { file ->
            if (file.extension == "apk" && file.name.startsWith("app-")) {
                val mode = file.name.substringAfter("app-").substringBefore(".apk")
                file.copyTo(File(flutterApkDir, "Samruddha-Kirana-Delivery-Agent-$mode.apk"), overwrite = true)
                file.copyTo(File(flutterApkDir, "Samruddha-Kirana-Delivery-Agent.apk"), overwrite = true)
            }
        }
    }
}

tasks.matching { it.name.startsWith("assemble") || it.name.startsWith("copyFlutterApks") }.configureEach {
    finalizedBy("copyCustomApk")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
