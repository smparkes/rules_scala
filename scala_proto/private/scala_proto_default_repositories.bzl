load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
    _scala_maven_install = "scala_maven_install",
)
# load(
#     "//scala:scala_cross_version.bzl",
#     _default_scala_version = "default_scala_version",
#     _extract_major_version = "extract_major_version",
#     _scala_mvn_artifact = "scala_mvn_artifact",
# )
# load(
#     "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
#     _scala_maven_import_external = "scala_maven_import_external",
# )

def scala_proto_default_repositories():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:
        configuration = _scala_version_configuration(version)

        _scala_maven_install(
            configuration = configuration,
            name = "{repo_prefix}scala_pb",
            artifacts = [
                "com.thesamet.scalapb:compilerplugin_{scala_major_version}:0.8.4",
                "com.thesamet.scalapb:protoc-bridge_{scala_major_version}:0.7.3",
                "com.thesamet.scalapb:scalapbc_{scala_major_version}:0.8.4",
                "com.thesamet.scalapb:scalapb-runtime_{scala_major_version}:0.8.4",
                "com.thesamet.scalapb:scalapb-runtime-grpc_{scala_major_version}:0.8.4",
                "com.thesamet.scalapb:lenses_{scala_major_version}:0.8.4",
                "com.lihaoyi:fastparse_{scala_major_version}:1.0.0",
            ],
        )

    _scala_maven_install(
        configuration = configuration,
        name = "{repo_prefix}grpc",
            artifacts = [
                "io.grpc:grpc-core:1.19.0",
                "io.grpc:grpc-stub:1.19.0",
                "io.grpc:grpc-protobuf:1.19.0",
                "io.grpc:grpc-netty:1.19.0",
                "io.grpc:grpc-context:1.19.0",
                "com.google.guava:guava:26.0-android",
                "com.google.instrumentation:instrumentation-api:0.3.0",
                "io.netty:netty-codec:4.1.32.Final",
                "io.netty:netty-codec-http:4.1.32.Final",
                "io.netty:netty-codec-socks:4.1.32.Final",
                "io.netty:netty-codec-http2:4.1.32.Final",
                "io.netty:netty-handler:4.1.32.Final",
                "io.netty:netty-buffer:4.1.32.Final",
                "io.netty:netty-transport:4.1.32.Final",
                "io.netty:netty-resolver:4.1.32.Final",
                "io.netty:netty-common:4.1.32.Final",
                "io.netty:netty-handler-proxy:4.1.32.Final",
                "io.opencensus:opencensus-api:0.22.1",
                "io.opencensus:opencensus-impl:0.22.1",
                "com.lmax:disruptor:3.4.2",
                "io.opencensus:opencensus-impl-core:0.22.1",
                "io.opencensus:opencensus-contrib-grpc-metrics:0.22.1",
            ],
    )
