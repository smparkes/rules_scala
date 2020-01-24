load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalacProvider = "ScalacProvider",
)

def _scala_bootstrap_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        enable_code_coverage_aspect = ctx.attr.enable_code_coverage_aspect,
        plus_one_deps_mode = ctx.attr.plus_one_deps_mode,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
        scalac = ctx.attr.scalac,
        scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        scalac_provider_attr = ctx.attr.scalac_provider_attr,
        scalacopts = ctx.attr.scalacopts,
    )
    return [toolchain, platform_common.TemplateVariableInfo({})]

scala_bootstrap_toolchain = rule(
    _scala_bootstrap_toolchain_impl,
    attrs = {
        "scalacopts": attr.string_list(),
        "plus_one_deps_mode": attr.string(
            default = "off",
            values = ["off", "on"],
        ),
        "enable_code_coverage_aspect": attr.string(
            default = "off",
            values = ["off", "on"],
        ),
        "scalac_jvm_flags": attr.string_list(),
        "scala_test_jvm_flags": attr.string_list(),
        "scalac": attr.label(),
        "scalac_provider_attr": attr.label(
            providers = [_ScalacProvider],
        ),
    },
)
def _scala_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        enable_code_coverage_aspect = ctx.attr.enable_code_coverage_aspect,
        plus_one_deps_mode = ctx.attr.plus_one_deps_mode,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
        scalac = ctx.attr.scalac,
        scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        scalac_provider_attr = ctx.attr.scalac_provider_attr,
        scalacopts = ctx.attr.scalacopts,
        unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode,
        unused_dependency_checker_plugin = ctx.attr.unused_dependency_checker_plugin,
    )
    return [toolchain, platform_common.TemplateVariableInfo({})]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        "scalacopts": attr.string_list(),
        "unused_dependency_checker_mode": attr.string(
            default = "off",
            values = ["off", "warn", "error"],
        ),
        "plus_one_deps_mode": attr.string(
            default = "off",
            values = ["off", "on"],
        ),
        "enable_code_coverage_aspect": attr.string(
            default = "off",
            values = ["off", "on"],
        ),
        "scalac_jvm_flags": attr.string_list(),
        "scala_test_jvm_flags": attr.string_list(),
        "scalac": attr.label(),
        "scalac_provider_attr": attr.label(
            providers = [_ScalacProvider],
        ),
        "unused_dependency_checker_plugin": attr.label(
            allow_files = [".jar"],
            mandatory = False,
        ),
    },
)

def _scalatest_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        reporter = ctx.attr.reporter,
        runner = ctx.attr.reporter,
    )
    return [toolchain, platform_common.TemplateVariableInfo({})]

scalatest_toolchain = rule(
    _scalatest_toolchain_impl,
    attrs = {
        "reporter": attr.label(),
        "runner": attr.label(),
    },
)
