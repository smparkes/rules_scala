load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)
load("//scala:scala.bzl", "scala_library")

def build():
    for version in _scala_configuration()["scala_versions"]:
        configuration = _scala_version_configuration(version)

        scala_library(
            name = "test_reporter-{scala_major_version}".format(**configuration),
            srcs = ["JUnitXmlReporter.scala"],
            scalacopts = [
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
                "-Yno-adapted-args",
                "-Ywarn-dead-code",
                "-Ywarn-numeric-widen",
                "-Ywarn-value-discard",
                "-Xfuture",
                "-Ywarn-unused-import",
                "-Ypartial-unification",
            ],
            visibility = ["//visibility:public"],
            deps = [
                "//scala/scalatest:scalatest-{scala_major_version}".format(**configuration),
                "@{scala_repo}//:org_scala_lang_modules_scala_xml_{scala_mvn_version}".format(**configuration),
            ],
            toolchains = ["//scala:scala-{scala_major_version}-scala-toolchain".format(**configuration)],
        )
