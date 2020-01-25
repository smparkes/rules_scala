#
# PHASE: unused deps checker
#
# DOCUMENT THIS
#

load("//scala:toolchains.bzl", _get_scala_toolchain = "get_scala_toolchain")

def phase_unused_deps_checker(ctx, p):
    if ctx.attr.unused_dependency_checker_mode:
        return ctx.attr.unused_dependency_checker_mode
    else:
        return _get_scala_toolchain(ctx).unused_dependency_checker_mode
