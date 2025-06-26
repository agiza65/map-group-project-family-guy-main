// android/build.gradle.kts

import org.gradle.api.tasks.Delete

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle 插件
        classpath("com.android.tools.build:gradle:7.4.1")
        // Google Services 插件
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 将 build 输出移到项目根目录外
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // 各子项目也使用外部 build 目录
    project.layout.buildDirectory.set(newBuildDir.dir(project.name))
    // 确保在 app 模块评估前先加载设置
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
