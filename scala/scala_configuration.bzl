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
}

def _repo_impl(ctx):
    ctx.file("scala_configuration.bzl", ctx.attr.scala_configuration)
    ctx.file("BUILD.bazel", 'exports_files(["scala_configuration.bzl"])')

_repo = repository_rule(
    implementation = _repo_impl,
    attrs = {
        "scala_configuration": attr.string(mandatory = True,),
    },
)

def scala_configuration(_configuration = {}):

    configuration = _dicts.add(
        _default_scala_configuration,
        _configuration
    )

    configuration["scala_versions"] = configuration["scala"].keys()

    scala_configuration = []
    scala_configuration.append("""load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")""")
    scala_configuration.append("_value = "+struct(value = configuration).to_json().replace(":null,", ":None,"))
    scala_configuration.append(
"""
def scala_configuration():
    configuration = _value["value"]
    # print(configuration)
    return configuration
"""
    )
    scala_configuration.append(
"""
def scala_configured_string(string):
    return string.format(**scala_configuration())

def scala_version_configuration(version):
    scala_major_version = ".".join(version.split(".")[0:2])
    scala_mvn_version = scala_major_version.replace(".", "_")

    configuration = scala_configuration()
    if False:
        print("a",configuration.keys())
        print("a",configuration["scala"])
        print("a",configuration)
        print("x",version)

    version_configuration = configuration["scala"][version]

    configuration = _dicts.add(
        configuration,
        version_configuration,
        {
          "scala_version": version,
          "scala_major_version": scala_major_version,
          "scala_mvn_version": scala_mvn_version,
        }
    )

    if not hasattr(configuration, "scala_repo"):
        configuration["scala_repo"] = configuration["repo_prefix"] + "scala_"+scala_mvn_version

    if not hasattr(configuration, "maven_install_json"):
        configuration["maven_install_json"] = configuration["maven_install_json_prefix"] + configuration["scala_repo"] + ".json" if configuration["maven_install_json_prefix"] else None

    # print(configuration)

    return configuration
"""
    )
    scala_configuration.append("")
    _repo(
        name = "io_bazel_rules_scala_configuration",
        scala_configuration = "\n".join(scala_configuration),
    )
