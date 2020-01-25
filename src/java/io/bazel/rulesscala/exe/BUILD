load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    "scala_configured_string",
)

java_library(
    name = "exe-lib",
    srcs = [
        "LaunchInfo.java",
        "LauncherFileWriter.java",
    ],
    visibility = ["//visibility:private"],
    deps = [
        "@bazel_tools//tools/java/runfiles",
        scala_configured_string("@{repo_prefix}exe//:com_google_guava_guava")
    ],
)

java_binary(
    name = "exe",
    data = [
        "@bazel_tools//tools/launcher",
    ],
    main_class = "io.bazel.rulesscala.exe.LauncherFileWriter",
    visibility = ["//visibility:public"],
    runtime_deps = [
        ":exe-lib",
    ],
)
