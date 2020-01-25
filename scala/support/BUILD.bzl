load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)
load("//scala:scala.bzl", "scala_library")

_scalacopts_common = [
    "-deprecation:true",
    "-encoding",
    "UTF-8",
    "-feature",
    "-language:existentials",
    "-language:higherKinds",
    "-language:implicitConversions",
    "-unchecked",
    "-Xfatal-warnings",
    "-Xlint",
    "-Ywarn-dead-code",
    "-Ywarn-numeric-widen",
    "-Ywarn-value-discard",
]

_scalacopts = {
    "2.11": _scalacopts_common + [
        "-Yno-adapted-args",
        "-Ywarn-unused-import",
        "-Ypartial-unification",
        "-Xfuture",
    ],
    "2.12": _scalacopts_common + [
        "-Yno-adapted-args",
        "-Ywarn-unused-import",
        "-Ypartial-unification",
        "-Xfuture",
    ],
    "2.13": _scalacopts_common + [
    ],
}

def build():
    for version in _scala_configuration()["scala_versions"]:
        configuration = _scala_version_configuration(version)

        scala_library(
            name = "test_reporter-{scala_major_version}".format(**configuration),
            srcs = ["JUnitXmlReporter.scala"],
            scalacopts = _scalacopts[configuration["scala_major_version"]],
            visibility = ["//visibility:public"],
            deps = [
                "//scala/scalatest:scalatest-{scala_major_version}".format(**configuration),
                "@{scala_repo}//:org_scala_lang_modules_scala_xml_{scala_mvn_version}".format(**configuration),
            ],
            toolchains = ["//scala:scala-{scala_major_version}-scala-toolchain".format(**configuration)],
        )
