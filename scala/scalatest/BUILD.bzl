load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)
load("//scala:scala_import.bzl", "scala_import")

def build():
    for version in _scala_configuration()["scala_versions"]:
        configuration = _scala_version_configuration(version)

        scala_import(
            name = "scalatest-{scala_major_version}".format(**configuration),
            jars = [],
            exports = [
                "@{scala_repo}//:org_scalatest_scalatest_{scala_mvn_version}".format(**configuration),
                "@{scala_repo}//:org_scalactic_scalactic_{scala_mvn_version}".format(**configuration),
            ],
            visibility = ["//visibility:public"],
        )
