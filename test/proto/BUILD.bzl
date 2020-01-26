load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)
load(
    "//scala_proto:scala_proto_toolchain.bzl",
    "scala_proto_toolchain",
)

def build():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:
        configuration = _scala_version_configuration(version)

        scala_proto_toolchain(
            name = "test_scala_proto_toolchain_configuration-{scala_major_version}".format(**configuration),
            # with_java=True,
            blacklisted_protos = [
                "//test/proto:blacklisted_proto",
                "//test/proto:other_blacklisted_proto",
            ],
            extra_generator_dependencies = [
                "//test/src/main/scala/scalarules/test/extra_protobuf_generator:extra_protobuf_generator-{scala_major_version}".format(**configuration),
            ],
            named_generators = {
                "jvm_extra_protobuf_generator": "scalarules.test.extra_protobuf_generator.ExtraProtobufGenerator",
            },
            visibility = ["//visibility:public"],
            with_flat_package = False,
            with_grpc = True,
            with_single_line_to_string = True,
        )

        native.toolchain(
            name = "scalapb_toolchain-{scala_major_version}".format(**configuration),
            toolchain = ":test_scala_proto_toolchain_configuration-{scala_major_version}".format(**configuration),
            toolchain_type = "@io_bazel_rules_scala//scala_proto:toolchain_type",
            visibility = ["//visibility:public"],
        )

def register_scalabp_toolchains():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:
        configuration = _scala_version_configuration(version)

        native.register_toolchains("@io_bazel_rules_scala//test/proto:scalapb_toolchain-{scala_major_version}".format(**configuration))
