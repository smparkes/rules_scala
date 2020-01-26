def scala_proto_register_toolchains():
    native.register_toolchains("@io_bazel_rules_scala//scala_proto:default_toolchain")

def scala_proto_register_enable_all_options_toolchain():
    native.register_toolchains("@io_bazel_rules_scala//scala_proto:enable_all_options_toolchain")

def get_scala_proto_toolchain(ctx):
    print(ctx)
    return ctx.toolchains
