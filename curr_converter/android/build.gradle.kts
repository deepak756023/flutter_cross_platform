import com.android.build.gradle.internal.dsl.BaseAppModuleExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

plugins.withId("com.android.application") {
    extensions.configure<BaseAppModuleExtension> {
        compileSdk = 34

        defaultConfig {
            minSdk = 21
            targetSdk = 34
        }

        // Set the required NDK version
        ndkVersion = "27.0.12077973"

        buildTypes {
            release {
                isMinifyEnabled = false
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
                )
            }
        }

        packagingOptions {
            jniLibs {
                excludes += listOf("META-INF/**")
            }
        }
    }
}
