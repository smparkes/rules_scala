load("//scala:scala.bzl", "scala_binary", "scala_library")
load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
    _scala_toolchain = "scala_toolchain",
    _jvm_external = "jvm_external",
)

def build():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:
        configuration = _scala_version_configuration(version)

        scala_library(
            name = "generator_lib-{scala_major_version}".format(**configuration),
            srcs = ["TwitterScroogeGenerator.scala"],
            visibility = ["//visibility:public"],
            deps = [
                # "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
                "//src/java/io/bazel/rulesscala/io_utils",
                "//src/java/io/bazel/rulesscala/jar",
                "//src/java/io/bazel/rulesscala/worker",
                "//src/scala/io/bazel/rules_scala/scrooge_support:compiler",
            ],
        )

        scala_binary(
            name = "generator-{scala_major_version}".format(**configuration),
            main_class = "scripts.ScroogeWorker",
            visibility = ["//visibility:public"],
            deps = [
                ":generator_lib-{scala_major_version}".format(**configuration),
            ],
        )

        scala_library(
            name = "scala_proto_request_extractor-{scala_major_version}".format(**configuration),
            srcs = ["PBGenerateRequest.scala"],
            visibility = ["//visibility:public"],
        )

        scala_library(
            name = "scalapb_generator_lib-{scala_major_version}".format(**configuration),
            srcs = ["ScalaPBGenerator.scala"],
            visibility = ["//visibility:public"],
            runtime_deps = [
                "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
            ],
            deps = [
                ":scala_proto_request_extractor-{scala_major_version}",
                "//external:io_bazel_rules_scala/dependency/proto/protoc_bridge",
                "//external:io_bazel_rules_scala/dependency/proto/scalapb_plugin",
                "//external:io_bazel_rules_scala/dependency/proto/scalapbc",
                "//src/java/io/bazel/rulesscala/io_utils",
                "//src/java/io/bazel/rulesscala/jar",
                "//src/java/io/bazel/rulesscala/worker",
            ],
        )

        scala_binary(
            name = "scalapb_generator-{scala_major_version}".format(**configuration),
            main_class = "scripts.ScalaPBWorker",
            visibility = ["//visibility:public"],
            deps = [
                ":scalapb_generator_lib-{scala_major_version}".format(**configuration),
            ],
        )
