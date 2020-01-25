load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)
load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

def build():
    for version in _scala_configuration()["scala_versions"]:
        configuration = _scala_version_configuration(version)

        scala_library_for_plugin_bootstrapping(
            name = "unused_dependency_checker-{scala_major_version}".format(**configuration),
            srcs = [
                "io/bazel/rulesscala/unuseddependencychecker/UnusedDependencyChecker.scala",
            ],
            resources = ["resources/scalac-plugin.xml"],
            visibility = ["//visibility:public"],
            deps = [
                "@{scala_repo}//:org_scala_lang_scala_compiler".format(**configuration),
                "@{scala_repo}//:org_scala_lang_scala_reflect".format(**configuration),
            ],
            toolchains = ["@io_bazel_rules_scala//scala:scala-{scala_major_version}-scala-bootstrap-toolchain".format(**configuration)],
        )
