load(
    ":scala_toolchain.bzl",
    "scala_bootstrap_toolchain",
    "scala_toolchain",
    "scalatest_toolchain",
)
load(
    ":providers.bzl",
    _declare_scalac_provider = "declare_scalac_provider",
)
load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)

def scala_toolchains():
    configuration = _scala_configuration()
    for version in configuration["scala_versions"]:
        configuration = _scala_version_configuration(version)

        scala_bootstrap_toolchain(
            name = "scala-{scala_major_version}-scala-bootstrap-toolchain".format(**configuration),
            scalac = "//src/java/io/bazel/rulesscala/scalac:scalac-{scala_major_version}".format(**configuration),
            scalac_provider_attr = ":scalac-{scala_major_version}".format(**configuration),
            visibility = ["//visibility:public"],
        )

        native.toolchain(
            name = "scala-{scala_major_version}-bootstrap-toolchain".format(**configuration),
            toolchain = "@io_bazel_rules_scala//scala:scala-{scala_major_version}-scala-bootstrap-toolchain".format(**configuration),
            toolchain_type = "@io_bazel_rules_scala//scala:bootstrap_toolchain_type",
            visibility = ["//visibility:public"],
        )

        scala_toolchain(
            name = "scala-{scala_major_version}-scala-toolchain".format(**configuration),
            scalac = "//src/java/io/bazel/rulesscala/scalac:scalac-{scala_major_version}".format(**configuration),
            scalac_provider_attr = "@io_bazel_rules_scala//scala:scalac-{scala_major_version}".format(**configuration),
            unused_dependency_checker_plugin = "//third_party/unused_dependency_checker/src/main:unused_dependency_checker-{scala_major_version}".format(**configuration),
            visibility = ["//visibility:public"],
        )

        native.toolchain(
            name = "scala-{scala_major_version}-toolchain".format(**configuration),
            toolchain = "@io_bazel_rules_scala//scala:scala-{scala_major_version}-scala-toolchain".format(**configuration),
            toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
            visibility = ["//visibility:public"],
        )

        scalatest_toolchain(
            name = "scala-{scala_major_version}-scala-scalatest-toolchain".format(**configuration),
            reporter = "//scala/support:test_reporter-{scala_major_version}".format(**configuration),
            runner = "//src/java/io/bazel/rulesscala/scala_test:runner-{scala_major_version}".format(**configuration),
            visibility = ["//visibility:public"],
        )

        native.toolchain(
            name = "scala-{scala_major_version}-scalatest-toolchain".format(**configuration),
            toolchain = "@io_bazel_rules_scala//scala:scala-{scala_major_version}-scala-scalatest-toolchain".format(**configuration),
            toolchain_type = "@io_bazel_rules_scala//scala:scalatest_toolchain_type",
            visibility = ["//visibility:public"],
        )

        _declare_scalac_provider(
            name = "scalac-{scala_major_version}".format(**configuration),
            default_classpath = [
                "@{scala_repo}//:org_scala_lang_scala_library".format(**configuration),
                "@{scala_repo}//:org_scala_lang_scala_reflect".format(**configuration),
            ],
            default_macro_classpath = [
                "@{scala_repo}//:org_scala_lang_scala_library".format(**configuration),
                "@{scala_repo}//:org_scala_lang_scala_reflect".format(**configuration),
            ],
            default_repl_classpath = [
                "@{scala_repo}//:org_scala_lang_scala_library".format(**configuration),
                "@{scala_repo}//:org_scala_lang_scala_reflect".format(**configuration),
                "@{scala_repo}//:org_scala_lang_scala_compiler".format(**configuration),
            ],
            default_scalatest_classpath = [
                "@{scala_repo}//:org_scalatest_scalatest_{scala_mvn_version}".format(**configuration),
                "@{scala_repo}//:org_scalactic_scalactic_{scala_mvn_version}".format(**configuration),
            ],
            visibility = ["//visibility:public"],
        )

    if hasattr(configuration, "default"):
        fail(configuration)

        native.register_toolchains(":default_toolchain")
        native.register_toolchains(":unused_dependency_checker_error_toolchain")

def get_scala_toolchain(ctx):
    for target in ctx.attr.toolchains:
        toolchain = target[platform_common.ToolchainInfo]
        if hasattr(toolchain, "scalac"):
            return toolchain
    return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]

def get_scalatest_toolchain(ctx):
    for target in ctx.attr.toolchains:
        toolchain = target[platform_common.ToolchainInfo]
        if hasattr(toolchain, "reporter"):
            return toolchain
    return ctx.toolchains["@io_bazel_rules_scala//scala:scalatest_toolchain_type"]
