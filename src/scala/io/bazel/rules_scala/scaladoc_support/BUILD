load("//scala:scala.bzl", "scala_binary")

# A simple scala_binary to run scaladoc.
# `bazel run` this target with "-help" as a param for usage text:
# bazel run -- "//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator" -help
scala_binary(
    name = "scaladoc_generator-2.11",
    main_class = "scala.tools.nsc.ScalaDoc",
    visibility = ["//visibility:public"],
    runtime_deps = [
        "@scala_2_11//:org_.scala_lang_modules_scala_parser_combinators_2_11",
        "@scala_2_11//:org_scala_lang_modules_:scala_xml_2_11",
        "@scala_2_11//:org_scala_lang_scala_compiler",
        "@scala_2_11//:org_scala_lang_scala_library",
        "@scala_2_11//:org_scala_lang_scala_reflect",
    ],
)

scala_binary(
    name = "scaladoc_generator-2.12",
    main_class = "scala.tools.nsc.ScalaDoc",
    visibility = ["//visibility:public"],
    runtime_deps = [
        "@scala_2_12//:org_.scala_lang_modules_scala_parser_combinators_2_12",
        "@scala_2_12//:org_scala_lang_modules_:scala_xml_2_12",
        "@scala_2_12//:org_scala_lang_scala_compiler",
        "@scala_2_12//:org_scala_lang_scala_library",
        "@scala_2_12//:org_scala_lang_scala_reflect",
    ],
)
