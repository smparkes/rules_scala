#
# PHASE: scalac provider
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalacProvider = "ScalacProvider",
)

def get_provider(ctx):
    if ctx.attr.toolchain:
        return ctx.attr.toolchain[platform_common.ToolchainInfo]
    else:
        print("C using default for", ctx)
        return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]

def phase_scalac_provider(ctx, p):
    return get_provider(ctx).scalac_provider_attr[_ScalacProvider]
