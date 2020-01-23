load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _declare_scalac_provider = "declare_scalac_provider",
)
load("//scala:scala_toolchain.bzl", "scala_toolchain")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "scala-2.11-scala-toolchain",
    scalac = "//src/java/io/bazel/rulesscala/scalac:scalac-2.11",
    scalac_provider_attr = ":scalac-2.11",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scala-2.11-toolchain",
    toolchain = ":scala-2.11-scala-toolchain",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "scala-2.12-scala-toolchain",
    scalac = "//src/java/io/bazel/rulesscala/scalac:scalac-2.12",
    scalac_provider_attr = ":scalac-2.12",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scala-2.12-toolchain",
    toolchain = ":scala-2.12-scala-toolchain",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "unused_dependency_checker_error_toolchain_impl",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "unused_dependency_checker_error_toolchain",
    toolchain = ":unused_dependency_checker_error_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

java_import(
    name = "bazel_test_runner_deploy",
    jars = ["@bazel_tools//tools/jdk:TestRunner_deploy.jar"],
    visibility = ["//visibility:public"],
)

_declare_scalac_provider(
    name = "scalac-2.11",
    default_classpath = [
        "@scala_2_11//:org_scala_lang_scala_library",
        "@scala_2_11//:org_scala_lang_scala_reflect",
    ],
    default_macro_classpath = [
        "@scala_2_11//:org_scala_lang_scala_library",
        "@scala_2_11//:org_scala_lang_scala_reflect",
    ],
    default_repl_classpath = [
        "@scala_2_11//:org_scala_lang_scala_library",
        "@scala_2_11//:org_scala_lang_scala_reflect",
        "@scala_2_11//:org_scala_lang_scala_compiler",
    ],
    visibility = ["//visibility:public"],
)

_declare_scalac_provider(
    name = "scalac-2.12",
    default_classpath = [
        "@scala_2_12//:org_scala_lang_scala_library",
        "@scala_2_12//:org_scala_lang_scala_reflect",
    ],
    default_macro_classpath = [
        "@scala_2_12//:org_scala_lang_scala_library",
        "@scala_2_12//:org_scala_lang_scala_reflect",
    ],
    default_repl_classpath = [
        "@scala_2_12//:org_scala_lang_scala_library",
        "@scala_2_12//:org_scala_lang_scala_reflect",
        "@scala_2_12//:org_scala_lang_scala_compiler",
    ],
    visibility = ["//visibility:public"],
)

java_library(
    name = "PlaceHolderClassToCreateEmptyJarForScalaImport",
    srcs = ["PlaceHolderClassToCreateEmptyJarForScalaImport.java"],
    visibility = ["//visibility:public"],
)
