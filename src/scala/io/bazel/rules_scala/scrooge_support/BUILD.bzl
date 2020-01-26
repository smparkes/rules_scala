load("//scala:scala.bzl", "scala_library")

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
            name = "compiler-{scala_major_version}".format(**configuration),
            srcs = ["Compiler.scala"],
            # util_core is still needed as a dep for older versions of scrooge
            unused_dependency_checker_mode = "off",
            visibility = ["//visibility:public"],
            deps = [
                ":focused_zip_importer-{scala_major_version}".format(**configuration),
            ] +  _jvm_external(configuration, "{scala_repo}", [
                "org.scala-lang.modules:scala-parser-combinators_{scala_major_version}",
            ]) + _jvm_external(configuration, "{repo_prefix}twitter_scrooge", [
                "com.twitter:scrooge-generator_{scala_major_version}",
                "com.twitter:util-core_{scala_major_version}",
                "com.twitter:util-logging_{scala_major_version}",
            ]),
        )

        scala_library(
            name = "focused_zip_importer-{scala_major_version}".format(**configuration),
            srcs = ["FocusedZipImporter.scala"],
            visibility = ["//visibility:public"],
            deps = _jvm_external(configuration, "{repo_prefix}twitter_scrooge", [
                "com.twitter:scrooge-generator_{scala_major_version}",
            ]),
        )
