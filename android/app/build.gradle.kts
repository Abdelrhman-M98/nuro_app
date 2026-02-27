plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin must be applied after Android and Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services Plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "ai.medical.nervix_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        
        applicationId = "ai.medical.nervix_app"
        
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
   
    implementation("com.google.firebase:firebase-analytics")
    
  
    implementation("androidx.multidex:multidex:2.0.1")
}