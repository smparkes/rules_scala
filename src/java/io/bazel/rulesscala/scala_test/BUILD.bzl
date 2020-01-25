load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)

def build():
    for version in _scala_configuration()["scala_versions"]:
        configuration = _scala_version_configuration(version)

        native.java_library(
           name = "runner-{scala_major_version}".format(**configuration),
           srcs = ["Runner.java"],
           visibility = ["//visibility:public"],
           deps = [
               "@{scala_repo}//:org_scalatest_scalatest_{scala_mvn_version}".format(**configuration),
               "@bazel_tools//tools/java/runfiles",
           ],
       )
