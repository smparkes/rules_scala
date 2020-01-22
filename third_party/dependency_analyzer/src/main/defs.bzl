load("@io_bazel_rules_scala//scala:advanced_usage/scala.bzl",
     "make_scala_library_for_plugin_bootstrapping",
)

scala_library_for_plugin_bootstrapping(
    name = "dependency_analyzer",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzer.scala",
    ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
    ],
    toolchain = "@//:scala-2.12-scala-toolchain",
)
