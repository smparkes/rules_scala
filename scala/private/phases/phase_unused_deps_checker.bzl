#
# PHASE: unused deps checker
#
# DOCUMENT THIS
#

def get_provider(ctx):
    if ctx.attr.toolchain:
        return ctx.attr.toolchain[platform_common.ToolchainInfo]
    else:
        print("D using default for", ctx)
        return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]

def phase_unused_deps_checker(ctx, p):
    if ctx.attr.unused_dependency_checker_mode:
        return ctx.attr.unused_dependency_checker_mode
    else:
        return get_provider(ctx).unused_dependency_checker_mode
