allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Fix: camera_android_camerax 0.6.30 配 camera-core 1.5.3 时，插件自身的编译
// classpath 缺少 androidx.concurrent:concurrent-futures（提供 CallbackToFutureAdapter），
// 导致 javac 处理 camera-core 的 jspecify 注解时报 "找不到类文件"。这里单独补上。
subprojects {
    plugins.withId("com.android.library") {
        if (project.name == "camera_android_camerax") {
            dependencies.add(
                "implementation",
                "androidx.concurrent:concurrent-futures:1.2.0"
            )
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
