// Top-level build.gradle.kts for Android

buildscript {
    // 👇 THIS WAS MISSING inside buildscript
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // We are commenting this out for now because you are running a Local App (SQLite).
        // If you enable this without a google-services.json file, the build will fail.
        // classpath("com.google.gms:google-services:4.4.0") 
        
        // This is required for Android builds
        classpath("com.android.tools.build:gradle:8.1.0") // Ensure this matches your Android Studio version
        classpath(kotlin("gradle-plugin", version = "1.9.0")) 
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}