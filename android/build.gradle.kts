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
    // Pub packages can live on another Windows drive. AGP's unit-test config
    // needs the package source and its build directory on the same drive.
    if (projectDir.toPath().root != newBuildDir.asFile.toPath().root) {
        val projectKey = rootProject.rootDir.absolutePath.hashCode().toUInt()
        project.layout.buildDirectory.set(
            java.io.File(
                gradle.gradleUserHomeDir,
                "flutter-plugin-builds/$projectKey/$name",
            ),
        )
    } else {
        project.layout.buildDirectory.value(newBuildDir.dir(project.name))
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
