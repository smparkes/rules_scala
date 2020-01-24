licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "unused_dependency_checker-2.11",
    srcs = [
        "io/bazel/rulesscala/unuseddependencychecker/UnusedDependencyChecker.scala",
    ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "@scala_2_11//:org_scala_lang_scala_compiler",
        "@scala_2_11//:org_scala_lang_scala_reflect",
    ],
    toolchains = ["@io_bazel_rules_scala//scala:scala-2.11-scala-bootstrap-toolchain"],
)

scala_library_for_plugin_bootstrapping(
    name = "unused_dependency_checker-2.12",
    srcs = [
        "io/bazel/rulesscala/unuseddependencychecker/UnusedDependencyChecker.scala",
    ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "@scala_2_12//:org_scala_lang_scala_compiler",
        "@scala_2_12//:org_scala_lang_scala_reflect",
    ],
    toolchains = ["@io_bazel_rules_scala//scala:scala-2.12-scala-bootstrap-toolchain"],
)
