allprojects {
    repositories {
        google()
        mavenCentral()
        // Onyx SDK repository
        maven { url = uri("https://jitpack.io") }
        maven { 
            url = uri("http://repo.boox.com/repository/maven-public/")
            isAllowInsecureProtocol = true
        }
        // Additional repositories for Onyx SDK dependencies
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { url = uri("https://repo1.maven.org/maven2/") }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
