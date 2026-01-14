import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        google()
        mavenCentral()
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

// --- كود إصلاح Namespace للمكتبات القديمة (Kotlin DSL) ---
subprojects {
    afterEvaluate {
        // البحث عن إعدادات الأندرويد داخل المكتبة
        val android = extensions.findByName("android")
        // التأكد من أنها مكتبة أندرويد
        if (android != null && android is BaseExtension) {
            // إذا لم يكن للمكتبة اسم تعريفي (Namespace)
            if (android.namespace == null) {
                // نمنحها اسماً افتراضياً لكي يقبلها النظام
                android.namespace = "com.bayt_al_attar.${project.name}"
            }
        }
    }
}