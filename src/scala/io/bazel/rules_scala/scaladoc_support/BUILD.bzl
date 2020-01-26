load("//scala:scala.bzl", "scala_binary")
load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _jvm_external = "jvm_external",
    _maybe_alias = "maybe_alias",
    _scala_configuration = "scala_configuration",
    _scala_toolchain = "scala_toolchain",
    _scala_version_configuration = "scala_version_configuration",
)

# A simple scala_binary to run scaladoc.
# `bazel run` this target with "-help" as a param for usage text:
# bazel run -- "//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator" -help

def build():
    for version in _scala_configuration()["scala_versions"]:
        configuration = _scala_version_configuration(version)

        scala_binary(
            name = "scaladoc_generator-{scala_major_version}".format(**configuration),
            main_class = "scala.tools.nsc.ScalaDoc",
            visibility = ["//visibility:public"],
            runtime_deps =
                _jvm_external(configuration, "{scala_repo}", [
                    "org.scala-lang.modules:scala-parser-combinators_{scala_major_version}",
                    "org.scala-lang.modules:scala-xml_{scala_major_version}",
                    "org.scala-lang.scala-compiler",
                    "org.scala-lang.scala-library",
                    "org.scala-lang.scala-reflect",
                ]),
            toolchains = [_scala_toolchain(version)],
        )

    _maybe_alias("scaladoc_generator")
