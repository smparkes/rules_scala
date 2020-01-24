load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "test_reporter-2.11",
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
        "@scala_2_11//:org_scala_lang_modules_scala_xml_2_11",
        "@scala_2_11//:org_scalatest_scalatest_2_11",
    ],
    toolchains = ["//scala:scala-2.11-scala-toolchain"],
)


scala_library(
    name = "test_reporter-2.12",
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
        "@scala_2_12//:org_scala_lang_modules_scala_xml_2_12",
        "@scala_2_12//:org_scalatest_scalatest_2_12",
    ],
    toolchains = ["//scala:scala-2.12-scala-toolchain"],
)
