load("//scala:scala.bzl", "scala_library")
load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
    _scala_toolchain = "scala_toolchain",
    _jvm_external = "jvm_external",
)

def scala_proto_default_repositories():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:
        configuration = _scala_version_configuration(version)

        scala_library(
            name = "extra_protobuf_generator-{scala_major_version}".format(**configuration),
            srcs = ["ExtraProtobufGenerator.scala"],
            visibility = ["//visibility:public"],
            deps =
            _jvm_external("{repo_prefix}scala_pb", [
                "com.thesamet.scalapb:protoc-bridge_{scala_major_version",
                "com.thesamet.scalapb:compilerplugin_{scala_major_version}",
            ]) + ["@com_google_protobuf//:protobuf_java"]
        )
