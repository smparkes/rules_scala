"""
Keeps direct compile dependencies of targets.
This enables targets to pass the to compiler the plus one dependencies in addition to the direct ones.
For motivation of plus one see the e2e tests
"""
PlusOneDeps = provider(
    fields = {
        "direct_deps": "list of direct compile dependencies of a target",
    },
)

def get_provider(ctx):
    if ctx.attr.toolchain:
      return ctx.attr.toolchain[platform_common.ToolchainInfo]
    else:
      print("A using default for", ctx)
      return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]

def _collect_plus_one_deps_aspect_impl(target, ctx):
    if (get_provider(ctx).plus_one_deps_mode == "off"):
        return []
    export_plus_one_deps = []
    for exported_dep in getattr(ctx.rule.attr, "exports", []):
        if PlusOneDeps in exported_dep:
            export_plus_one_deps.extend(exported_dep[PlusOneDeps].direct_deps)
    return [PlusOneDeps(direct_deps = export_plus_one_deps + getattr(ctx.rule.attr, "deps", []))]

collect_plus_one_deps_aspect = aspect(
    implementation = _collect_plus_one_deps_aspect_impl,
    attr_aspects = ["deps", "exports"],
    toolchains = [
        "@io_bazel_rules_scala//scala:toolchain_type",
    ],
)
