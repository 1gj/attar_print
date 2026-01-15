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

// --- كود إصلاح Namespace للمكتبات القديمة (مصحح وشامل) ---
subprojects {
    val configureNamespace = {
        val android = extensions.findByName("android")
        // التأكد من أنها مكتبة أندرويد
        if (android != null && android is BaseExtension) {
            
            // [إصلاح خاص] لمكتبة blue_thermal_printer
            // نعطيها اسمها الأصلي لمنع التعارض مع ملف Manifest
            if (project.name == "blue_thermal_printer") {
                android.namespace = "id.kakzaki.blue_thermal_printer"
            }
            
            // باقي المكتبات التي ليس لها اسم، نعطيها اسماً افتراضياً
            else if (android.namespace == null) {
                val validNamespace = "com.bayt_al_attar.${project.name.replace("-", "_")}"
                android.namespace = validNamespace
            }
        }
    }

    // تنفيذ الإصلاح سواء تم تقييم المشروع أم لا (لتجنب أخطاء التوقيت)
    if (state.executed) {
        configureNamespace()
    } else {
        afterEvaluate {
            configureNamespace()
        }
    }
}