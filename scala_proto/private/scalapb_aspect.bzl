load(
    "//scala/private:common.bzl",
    "write_manifest_file",
)
load("//scala/private:rule_impls.bzl", "compile_scala")
load("//scala_proto/private:proto_to_scala_src.bzl", "proto_to_scala_src")
load("//scala_proto:toolchains.bzl", _get_scala_proto_toolchain = "get_scala_proto_toolchain")

ScalaPBAspectInfo = provider(fields = [
    "proto_info",
    "src_jars",
    "output_files",
    "java_info",
])

ScalaPBImport = provider(fields = [
    "java_info",
    "proto_info",
])

ScalaPBInfo = provider(fields = [
    "aspect_info",
])

def merge_proto_infos(tis):
    return struct(
        transitive_sources = [t.transitive_sources for t in tis],
    )

def merge_scalapb_aspect_info(scalapbs):
    return ScalaPBAspectInfo(
        src_jars = depset(transitive = [s.src_jars for s in scalapbs]),
        output_files = depset(transitive = [s.output_files for s in scalapbs]),
        proto_info = merge_proto_infos([s.proto_info for s in scalapbs]),
        java_info = java_common.merge([s.java_info for s in scalapbs]),
    )

def _compiled_jar_file(actions, scalapb_jar):
    scalapb_jar_name = scalapb_jar.basename

    # ends with .srcjar, so remove last 6 characters
    without_suffix = scalapb_jar_name[0:len(scalapb_jar_name) - 6]

    # this already ends with _scalapb because that is how scalapb_jar is named
    compiled_jar = without_suffix + "jar"
    return actions.declare_file(compiled_jar, sibling = scalapb_jar)

def _compile_scala(
        ctx,
        scalac,
        label,
        output,
        scalapb_jar,
        deps_java_info,
        implicit_deps,
        resources,
        resource_strip_prefix):
    manifest = ctx.actions.declare_file(
        label.name + "_MANIFEST.MF",
        sibling = scalapb_jar,
    )
    write_manifest_file(ctx.actions, manifest, None)
    statsfile = ctx.actions.declare_file(
        label.name + "_scalac.statsfile",
        sibling = scalapb_jar,
    )
    merged_deps = java_common.merge(_concat_lists(deps_java_info, implicit_deps))

    # this only compiles scala, not the ijar, but we don't
    # want the ijar for generated code anyway: any change
    # in the proto generally will change the interface and
    # method bodies
    compile_scala(
        ctx,
        Label("%s-fast" % (label)),
        output,
        manifest,
        statsfile,
        sources = [],
        cjars = merged_deps.compile_jars,
        all_srcjars = depset([scalapb_jar]),
        transitive_compile_jars = merged_deps.transitive_compile_time_jars,
        plugins = [],
        resource_strip_prefix = resource_strip_prefix,
        resources = resources,
        resource_jars = [],
        labels = {},
        in_scalacopts = [],
        print_compile_time = False,
        expect_java_output = False,
        scalac_jvm_flags = [],
        scalac = scalac,
    )

    return JavaInfo(
        source_jar = scalapb_jar,
        deps = deps_java_info + implicit_deps,
        runtime_deps = deps_java_info + implicit_deps,
        exports = deps_java_info + implicit_deps,
        output_jar = output,
        compile_jar = output,
    )

####
# This is applied to the DAG of proto_librarys reachable from a deps
# or a scalapb_scala_library. Each proto_library will be one scalapb
# invocation assuming it has some sources.
def _scalapb_aspect_impl(target, ctx):
    deps = [d[ScalaPBAspectInfo].java_info for d in ctx.rule.attr.deps]

    if ProtoInfo not in target:
        # We allow some dependencies which are not protobuf, but instead
        # are jvm deps. This is to enable cases of custom generators which
        # add a needed jvm dependency.
        java_info = target[JavaInfo]
        src_jars = depset()
        outs = depset()
        transitive_ti = merge_proto_infos(
            [
                d[ScalaPBAspectInfo].proto_info
                for d in ctx.rule.attr.deps
            ],
        )
    else:
        target_ti = target[ProtoInfo]
        transitive_ti = merge_proto_infos(
            [
                d[ScalaPBAspectInfo].proto_info
                for d in ctx.rule.attr.deps
            ] + [target_ti],
        )

        # we sort so the inputs are always the same for caching
        compile_protos = sorted(target_ti.direct_sources)
        transitive_protos = sorted(target_ti.transitive_sources.to_list())

        toolchain = _get_scala_proto_toolchain(ctx)
        flags = []
        imps = [j[JavaInfo] for j in ctx.attr._implicit_compile_deps]

        if toolchain.with_grpc:
            flags.append("grpc")
            imps.extend([j[JavaInfo] for j in ctx.attr._grpc_deps])

        if toolchain.with_flat_package:
            flags.append("flat_package")

        if toolchain.with_single_line_to_string:
            flags.append("single_line_to_proto_string")

        extra_generator_jars = []
        for generator_dep in toolchain.extra_generator_dependencies:
            jinfo = generator_dep[JavaInfo]
            extra_generator_jars.extend(jinfo.transitive_runtime_jars.to_list())

        # This feels rather hacky and odd, but we can't compare the labels to ignore a target easily
        # since the @ or // forms seem to not have good equality :( , so we aim to make them absolute
        #
        # the backlisted protos in the tool chain get made into to absolute paths
        # so we make the local target we are looking at absolute too
        target_absolute_label = target.label
        if not str(target_absolute_label)[0] == "@":
            target_absolute_label = Label("@%s//%s:%s" % (ctx.workspace_name, target.label.package, target.label.name))

        for lbl in toolchain.blacklisted_protos:
            if (lbl.label == target_absolute_label):
                compile_protos = False

        code_generator = toolchain.code_generator

        if compile_protos:
            scalapb_file = ctx.actions.declare_file(
                target.label.name + "_scalapb.srcjar",
            )
            proto_to_scala_src(
                ctx,
                target.label,
                code_generator,
                compile_protos,
                transitive_protos,
                target_ti.transitive_proto_path.to_list(),
                flags,
                scalapb_file,
                toolchain.named_generators,
                sorted(extra_generator_jars),
            )

            src_jars = depset([scalapb_file])
            output = _compiled_jar_file(ctx.actions, scalapb_file)
            outs = depset([output])
            java_info = _compile_scala(
                ctx,
                toolchain.scalac,
                target.label,
                output,
                scalapb_file,
                deps,
                imps,
                compile_protos,
                "" if target_ti.proto_source_root == "." else target_ti.proto_source_root,
            )
        else:
            # this target is only an aggregation target
            src_jars = depset()
            outs = depset()
            java_info = java_common.merge(_concat_lists(deps, imps))

    return [
        ScalaPBAspectInfo(
            src_jars = src_jars,
            output_files = outs,
            proto_info = transitive_ti,
            java_info = java_info,
        ),
    ]

def _concat_lists(list1, list2):
    all_providers = []
    all_providers.extend(list1)
    all_providers.extend(list2)
    return all_providers

scalapb_aspect = aspect(
    implementation = _scalapb_aspect_impl,
    attr_aspects = ["deps"],
    required_aspect_providers = [
        [ProtoInfo],
        [ScalaPBImport],
    ],
    attrs = {
        "_protoc": attr.label(executable = True, cfg = "host", default = "@com_google_protobuf//:protoc"),
        # "_implicit_compile_deps": attr.label_list(cfg = "target", default = [
        #     "//external:io_bazel_rules_scala/dependency/proto/implicit_compile_deps",
        # ]),
        # "_grpc_deps": attr.label_list(cfg = "target", default = [
        #     "//external:io_bazel_rules_scala/dependency/proto/grpc_deps",
        # ]),
    },
    toolchains = [
        "@io_bazel_rules_scala//scala:toolchain_type",
        "@io_bazel_rules_scala//scala_proto:toolchain_type",
    ],
)
