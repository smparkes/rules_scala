#
# PHASE: scalac provider
#
# DOCUMENT THIS
#
load("//scala:providers.bzl", _ScalacProvider = "ScalacProvider")
load("//scala:toolchains.bzl", _get_scala_toolchain = "get_scala_toolchain")

def phase_scalac_provider(ctx, p):
    scalac_provider = _get_scala_toolchain(ctx).scalac_provider_attr
    if scalac_provider == None:
        fail("no scalac provider resolved")
    return scalac_provider[_ScalacProvider]
