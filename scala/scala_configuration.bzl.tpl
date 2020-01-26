# -*- mode: python -*-

load("@rules_jvm_external//:defs.bzl", _maven_install = "maven_install")
load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")

_dict = %{CONFIGURATION_STRING}

def scala_configuration():
    configuration = _dict["value"]
    # print(configuration)
    return configuration

def versioned_file(file, version):
    configuration = scala_version_configuration(version)
    components = file.split(".")
    components[0] = components[0] + "_{scala_mvn_version}"
    glob_string = ".".join(components).format(**configuration)
    array = (native.glob([glob_string]) + [file])[0:1]
    return array

def jvm_external(configuration, repo, strings):
    labels = []
    repo_prefix = "@%s//:" % repo.format(**configuration)
    for string in strings:
        labels.append(
            repo_prefix + string.format(**configuration).replace(".", "_").replace(":", "_").replace("-", "_")
        )
    return labels

def version_to_major_version(version):
    components = version.split(".")
    return ".".join(components[0:2])

def maybe_alias(target):
    if "default" in scala_configuration():
        native.alias(
            name = target,
            actual = target + "-" + scala_configuration()["default"]
        )

def scala_toolchain(version):
    return "@io_bazel_rules_scala//scala:scala-%s-scala-toolchain" % version_to_major_version(version)

def scalatest_toolchain(version):
    return "@io_bazel_rules_scala//scala:scala-%s-scala-scalatest-toolchain" % version_to_major_version(version)

def scala_configured_string(string):
    return string.format(**scala_configuration())

def scala_version_configuration(version):
    scala_major_version = ".".join(version.split(".")[0:2])
    scala_mvn_version = scala_major_version.replace(".", "_")

    configuration = scala_configuration()

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

def maven_install(
        configuration,
        name,
        artifacts,
        repositories = None,
        version_conflict_policy = None,
        maven_install_json = None,
):
    resolved = {}
    resolved["name"] = name.format(**configuration)
    resolved["repositories"] = repositories if repositories else configuration["repositories"]
    resolved["version_conflict_policy"] = version_conflict_policy if version_conflict_policy else configuration["version_conflict_policy"]
    resolved["maven_install_json"] = maven_install_json if maven_install_json else configuration["maven_install_json"]

    resolved["artifacts"] = []

    for artifact in artifacts:
        resolved["artifacts"].append(artifact.format(**configuration))

    _maven_install(**resolved)
