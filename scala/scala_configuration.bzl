load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")

_default_scala_configuration = {
    "scala": {
        "2.11.12": {},
    },
    "default": "2.11",
    "scalatest": "3.1.0",
    "scala-xml": "1.2.0",
    "scala-parser-combinators": "1.1.2",
    "repositories": [
        "https://jcenter.bintray.com/",
        "https://maven.google.com",
        "https://repo1.maven.org/maven2",
    ],
    "repo_prefix": "io_bazel_rules_scala_repo_",
    "version_conflict_policy": "pinned",
    "maven_install_json_prefix": None,
    "toolchains": {
        "enable_code_coverage_aspect": "off",
        "plus_one_deps_mode": "off",
        "scala_test_jvm_flags": [],
        "scalac_jvm_flags": [],
        "scalaopts": [],
        "unused_dependency_checker_mode": "off",
    },
}

def _repo_impl(ctx):
    ctx.file("BUILD.bazel", 'exports_files(["scala_configuration.bzl"])')
    ctx.template(
        "scala_configuration.bzl",
        ctx.attr._template,
        substitutions = {"%{CONFIGURATION_STRING}": ctx.attr.configuration_string}
    )

_repo = repository_rule(
    implementation = _repo_impl,
    attrs = {
        "configuration_string": attr.string(mandatory = True),
        "_template": attr.label(
            default = ":scala_configuration.bzl.tpl",
        )
    },
)

def scala_configuration(_configuration = {}):
    _toolchain_configuration = {}

    configuration = _dicts.add(
        _default_scala_configuration,
        _configuration,
    )

    configuration["scala_versions"] = configuration["scala"].keys()

    _repo(
        name = "io_bazel_rules_scala_configuration",
        configuration_string = struct(value = configuration).to_json().replace(":null,", ":None,"),
    )
