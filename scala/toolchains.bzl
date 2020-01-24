load(
    ":scala_toolchain.bzl",
    "scala_toolchain",
    "scala_bootstrap_toolchain",
    "scalatest_toolchain"
)
load(
    ":providers.bzl",
    _declare_scalac_provider = "declare_scalac_provider",
)

def scala_register_toolchains():
    native.register_toolchains(":default_toolchain")

def scala_register_unused_deps_toolchains():
    native.register_toolchains(":unused_dependency_checker_error_toolchain")

def toolchains(scala_versions = []):
    for scala_version in scala_versions:

        scala_bootstrap_toolchain(
            name = "scala-%s-scala-bootstrap-toolchain" % scala_version,
            scalac = "//src/java/io/bazel/rulesscala/scalac:scalac-%s" % scala_version,
            scalac_provider_attr = ":scalac-%s" % scala_version,
            visibility = ["//visibility:public"],
        )

        native.toolchain(
            name = "scala-%s-bootstrap-toolchain" % scala_version,
            toolchain = ":scala-%s-scala-bootstrap-toolchain" % scala_version,
            toolchain_type = "@io_bazel_rules_scala//scala:bootstrap_toolchain_type",
            visibility = ["//visibility:public"],
        )

        scala_toolchain(
            name = "scala-%s-scala-toolchain" % scala_version,
            scalac = "//src/java/io/bazel/rulesscala/scalac:scalac-%s" % scala_version,
            scalac_provider_attr = ":scalac-%s" % scala_version,
            unused_dependency_checker_plugin =
            "//third_party/unused_dependency_checker/src/main:unused_dependency_checker-%s" % scala_version,
            visibility = ["//visibility:public"],
        )

        native.toolchain(
            name = "scala-%s-toolchain" % scala_version,
            toolchain = ":scala-%s-scala-toolchain" % scala_version,
            toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
            visibility = ["//visibility:public"],
        )

        scalatest_toolchain(
            name = "scala-%s-scalatest-toolchain" % scala_version,
            reporter = "//scala/support:test_reporter-%s" % scala_version,
            runner = "//src/java/io/bazel/rulesscala/scala_test:runner-%s" % scala_version,
            visibility = ["//visibility:public"],
        )

        native.toolchain(
            name = "scalatest-%s-toolchain" % scala_version,
            toolchain = ":scala-%s-scalatest-toolchain" % scala_version,
            toolchain_type = "@io_bazel_rules_scala//scala:scalatest_toolchain_type",
            visibility = ["//visibility:public"],
        )

        scala_repo = "@scala_" + scala_version.replace(".", "_")

        _declare_scalac_provider(
            name = "scalac-%s" % scala_version,
            default_classpath = [
                scala_repo + "//:org_scala_lang_scala_library",
                scala_repo + "//:org_scala_lang_scala_reflect",
            ],
            default_macro_classpath = [
                scala_repo + "//:org_scala_lang_scala_library",
                scala_repo + "//:org_scala_lang_scala_reflect",
            ],
            default_repl_classpath = [
                scala_repo + "//:org_scala_lang_scala_library",
                scala_repo + "//:org_scala_lang_scala_reflect",
                scala_repo + "//:org_scala_lang_scala_compiler",
            ],
            default_scalatest_classpath = [
                scala_repo + "//:org_scalatest_scalatest_%s" % scala_version.replace(".", "_"),
            ],
            visibility = ["//visibility:public"],
        )

def get_scala_toolchain(ctx):
    print("a", ctx)
    for target in ctx.attr.toolchains:
        print("b", target)
        toolchain = target[platform_common.ToolchainInfo]
        if hasattr(toolchain, "scalac"):
            return toolchain
    print("c", ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"])
    return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]

def get_scalatest_toolchain(ctx):
    for target in ctx.attr.toolchains:
        toolchain = target[platform_common.ToolchainInfo]
        if hasattr(toolchain, "reporter"):
            return toolchain
    return ctx.toolchains["@io_bazel_rules_scala//scala:scalatest_toolchain_type"]
