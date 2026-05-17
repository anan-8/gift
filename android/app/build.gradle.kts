plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
<<<<<<< HEAD
    id("com.google.gms.google-services") 
=======
    id("com.google.gms.google-services") // ✅ لتفعيل Firebase
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
}

android {
    namespace = "com.example.gift"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.gift"
<<<<<<< HEAD
        minSdk = flutter.minSdkVersion
=======
        minSdk = 23
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlinOptions {
    jvmTarget = JavaVersion.VERSION_17.toString()
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
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}
