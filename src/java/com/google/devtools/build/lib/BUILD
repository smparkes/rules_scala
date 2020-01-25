load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    "scala_configured_string",
)

java_library(
    name = "worker",
    srcs = ["WorkerProtocol.java"],
    visibility = ["//visibility:public"],
    exports = [
        scala_configured_string("@{repo_prefix}worker//:com_google_protobuf_protobuf_java"),
    ],
    deps = [
        scala_configured_string("@{repo_prefix}worker//:com_google_protobuf_protobuf_java"),
    ],
)
