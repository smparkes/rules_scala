load(":scala_toolchain.bzl", "scala_toolchain")
load(":toolchains.bzl", "toolchains")

toolchain_type(
    name = "bootstrap_toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "scalatest_toolchain_type",
    visibility = ["//visibility:public"],
)

toolchains(["2.11", "2.12", "2.13"])

# scala_toolchain(
#     name = "unused_dependency_checker_error_toolchain_impl",
#     unused_dependency_checker_mode = "error",
#     visibility = ["//visibility:public"],
# )

# toolchain(
#     name = "unused_dependency_checker_error_toolchain",
#     toolchain = ":unused_dependency_checker_error_toolchain_impl",
#     toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
#     visibility = ["//visibility:public"],
# )

java_import(
    name = "bazel_test_runner_deploy",
    jars = ["@bazel_tools//tools/jdk:TestRunner_deploy.jar"],
    visibility = ["//visibility:public"],
)


java_library(
    name = "PlaceHolderClassToCreateEmptyJarForScalaImport",
    srcs = ["PlaceHolderClassToCreateEmptyJarForScalaImport.java"],
    visibility = ["//visibility:public"],
)
