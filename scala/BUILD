load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _declare_scalac_provider = "declare_scalac_provider",
)
load("//scala:scala_toolchain.bzl", "scala_toolchain")

toolchain_type(
    name = "bootstrap_toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "default_bootstrap_toolchain",
    scalacopts = [],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "default_native_bootstrap_toolchain",
    toolchain = ":default_bootstrap_toolchain",
    toolchain_type = "@io_bazel_rules_scala//scala:boostrap_toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "xdefault_toolchain",
    scalacopts = [],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "default_native_toolchain",
    toolchain = ":xdefault_toolchain",
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
    name = "scalac_default",
    default_classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
    ],
    default_macro_classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
    ],
    default_repl_classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "@io_bazel_rules_scala_scala_compiler",
    ],
    visibility = ["//visibility:public"],
)

java_library(
    name = "PlaceHolderClassToCreateEmptyJarForScalaImport",
    srcs = ["PlaceHolderClassToCreateEmptyJarForScalaImport.java"],
    visibility = ["//visibility:public"],
)
