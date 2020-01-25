load(":scala_toolchain.bzl", "scala_toolchain")
load(":toolchains.bzl", "scala_toolchains")
load(":scala_repositories.bzl", "pin_targets", "unpin_targets")

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

scala_toolchains()

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

genrule(
    name = "pin",
    srcs = [],  #
    outs = ["pin.sh"],
    cmd = "echo $(location tools)",
    executable = True,
    tools = pin_targets(),
)
