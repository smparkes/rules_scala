load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)
load(
    ":jvm_export_toolchain.bzl",
    _export_scalac_repositories_from_toolchain_to_jvm = "export_scalac_repositories_from_toolchain_to_jvm",
)

def build():
    for version in _scala_configuration()["scala_versions"]:
        configuration = _scala_version_configuration(version)

        _export_scalac_repositories_from_toolchain_to_jvm(
            name = "exported_{scala_mvn_version}_scalac_repositories_from_toolchain_to_jvm".format(**configuration),
            scalac_provider = "//scala:scalac-{scala_major_version}".format(**configuration),
        )

        native.java_binary(
            name = "scalac-{scala_major_version}".format(**configuration),
            srcs = [
                "CompileOptions.java",
                "Resource.java",
                "ScalaCInvoker.java",
            ] + [
                (native.glob(["ScalacProcessor_{scala_mvn_version}.java".format(**configuration)]) + ["ScalacProcessor.java"])[0]
            ],
            javacopts = [
                "-source 1.8",
                "-target 1.8",
            ],
            main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
            visibility = ["//visibility:public"],
            deps = [
                ":exported_{scala_mvn_version}_scalac_repositories_from_toolchain_to_jvm".format(**configuration),
                "@io_bazel_rules_scala//src/java/com/google/devtools/build/lib:worker",
                "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
                "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
                "@{repo_prefix}scalac//:commons_io_commons_io".format(**configuration),
            ],
        )
