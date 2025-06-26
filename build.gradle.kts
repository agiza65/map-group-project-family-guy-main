plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")        // ← 加在这里
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion  // 通常是 33

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // 开启核心库反糖
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
         manifestPlaceholders["GOOGLE_MAPS_API_KEY"]= "AIzaSyCJHu-D1S_dPa7Wzr5Eqw9lZZh5zVt0EuM"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM 管理各服务版本
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    // 下面是常用的 Firebase 依赖示例：
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-firestore")
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:1.2.2")
}
