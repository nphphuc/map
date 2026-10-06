// MapLibre compiles Java 21 sources even though the app targets Java 17.
if (JavaVersion.current() < JavaVersion.VERSION_21) {
    throw GradleException(
        "MapLibre requires JDK 21+ to build. Gradle is running on ${JavaVersion.current()}. " +
            "Set Flutter's JDK with: flutter config --jdk-dir=\"<JDK 21+ directory>\". " +
            "See the Android Studio section in README.md."
    )
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
