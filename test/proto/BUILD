load(
    "//scala_proto:scala_proto.bzl",
    "scala_proto_library",
)
load(
    "//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
)
load(
    "//scala_proto:scala_proto_toolchain.bzl",
    "scala_proto_toolchain",
)

scala_proto_toolchain(
    name = "test_scala_proto_toolchain_configuration",
    # with_java=True,
    blacklisted_protos = [
        "//test/proto:blacklisted_proto",
        "//test/proto:other_blacklisted_proto",
    ],
    extra_generator_dependencies = [
        "//test/src/main/scala/scalarules/test/extra_protobuf_generator",
    ],
    named_generators = {
        "jvm_extra_protobuf_generator": "scalarules.test.extra_protobuf_generator.ExtraProtobufGenerator",
    },
    visibility = ["//visibility:public"],
    with_flat_package = False,
    with_grpc = True,
    with_single_line_to_string = True,
)

toolchain(
    name = "scalapb_toolchain",
    toolchain = ":test_scala_proto_toolchain_configuration",
    toolchain_type = "@io_bazel_rules_scala//scala_proto:toolchain_type",
    visibility = ["//visibility:public"],
)

proto_library(
    name = "blacklisted_proto",
    srcs = ["blacklisted_proto.proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "other_blacklisted_proto",
    srcs = ["blacklisted_proto.proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "test2",
    srcs = ["test2.proto"],
    visibility = ["//visibility:public"],
    deps = ["//test/proto2:test"],
)

proto_library(
    name = "test3",
    srcs = ["test3.proto"],
    visibility = ["//visibility:public"],
    deps = ["//test/proto2:test"],
)

proto_library(
    name = "test_external_dep_proto",
    srcs = ["test_external_dep.proto"],
    visibility = ["//visibility:public"],
    deps = [
        "@com_google_protobuf//:wrappers_proto",
    ],
)

scala_proto_library(
    name = "test_external_dep",
    visibility = ["//visibility:public"],
    deps = [":test_external_dep_proto"],
)

# Test that the `proto_source_root` attribute is handled properly
proto_library(
    name = "strip_import_prefix",
    srcs = [
        "different_root.proto",
        "different_root2.proto",
    ],
    strip_import_prefix = "",
    visibility = ["//visibility:public"],
)

scala_proto_library(
    name = "test_strip_import_prefix",
    visibility = ["//visibility:public"],
    deps = [":strip_import_prefix"],
)

proto_library(
    name = "test_service",
    srcs = ["test_service.proto"],
    visibility = ["//visibility:public"],
    deps = [
        ":test2",
        ":test3",
        "//test/proto2:test",
    ],
)

scala_proto_library(
    name = "test_proto_nogrpc",
    visibility = ["//visibility:public"],
    deps = [":test2"],
)

scala_binary(
    name = "test_binary_to_ensure_no_host_deps",
    main_class = "a.b.c",
    visibility = ["//visibility:public"],
    deps = [":test_proto_nogrpc"],
)

java_proto_library(
    name = "test_proto_java_lib",
    deps = [
        ":test2",
        "//test/proto2:test",
    ],
)

scala_proto_library(
    name = "test_proto_java_conversions",
    visibility = ["//visibility:public"],
    deps = [
        ":test2",
        "//test/proto2:test",
    ],
)

scala_proto_library(
    name = "test_proto",
    visibility = ["//visibility:public"],
    deps = [
        ":blacklisted_proto",
        ":test_service",
        "@io_bazel_rules_scala//test/proto:other_blacklisted_proto",
    ],
)

scala_test(
    name = "test_blacklisted_proto",
    srcs = [
        "BlackListedProtoTest.scala",
    ],
    deps = [
        ":test_proto",
    ],
)

scala_test(
    name = "test_custom_object_exists",
    srcs = [
        "CustomGeneratedObjectTest.scala",
    ],
    deps = [
        ":test_external_dep",
    ],
)

proto_library(
    name = "standalone_proto",
    srcs = ["standalone.proto"],
)

proto_library(
    name = "standalone_proto_strip_import_prefix_partial",
    srcs = ["standalone.proto"],
    strip_import_prefix = "/test",
)

proto_library(
    name = "standalone_proto_strip_import_prefix_package",
    srcs = ["standalone.proto"],
    strip_import_prefix = "/" + package_name(),
)

proto_library(
    name = "standalone_proto_with_import_prefix",
    srcs = ["standalone.proto"],
    import_prefix = "prefix",
)

proto_library(
    name = "standalone_proto_with_custom_prefix",
    srcs = ["standalone.proto"],
    import_prefix = "prefix",
    strip_import_prefix = "/test",
)

proto_library(
    name = "nested_proto",
    srcs = ["some/path/nested.proto"],
)

proto_library(
    name = "nested_proto_strip_import_prefix_relative",
    srcs = ["some/path/nested.proto"],
    strip_import_prefix = "some",
)

proto_library(
    name = "nested_proto_with_import_prefix",
    srcs = ["some/path/nested.proto"],
    import_prefix = "prefix",
)

proto_library(
    name = "nested_proto_with_custom_prefix",
    srcs = ["some/path/nested.proto"],
    import_prefix = "prefix",
    strip_import_prefix = "some",
)

scala_proto_library(
    name = "pack_protos_lib",
    deps = [
        ":nested_proto",
        ":nested_proto_strip_import_prefix_relative",
        ":nested_proto_with_custom_prefix",
        ":nested_proto_with_import_prefix",
        ":standalone_proto",
        ":standalone_proto_strip_import_prefix_package",
        ":standalone_proto_strip_import_prefix_partial",
        ":standalone_proto_with_custom_prefix",
        ":standalone_proto_with_import_prefix",
    ],
)

scala_test(
    name = "test_pack_protos",
    srcs = ["PackProtosTest.scala"],
    unused_dependency_checker_mode = "off",
    deps = [":pack_protos_lib"],
)
