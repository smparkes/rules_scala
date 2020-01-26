load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
    _maven_install = "maven_install",
)
# load("@rules_jvm_external//:defs.bzl", _maven_install = "maven_install")
load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")

def scala_repositories():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:
        configuration = _scala_version_configuration(version)

        _maven_install(
            configuration = configuration,
            name = "{scala_repo}",
            artifacts = [
                "org.scala-lang:scala-compiler:{scala_version}",
                "org.scala-lang:scala-library:{scala_version}",
                "org.scala-lang:scala-reflect:{scala_version}",
                "org.scalatest:scalatest_{scala_major_version}:{scalatest}",
                "org.scalactic:scalactic_{scala_major_version}:{scalatest}",
                "org.scala-lang.modules:scala-xml_{scala_major_version}:{scala-xml}",
                "org.scala-lang.modules:scala-parser-combinators_{scala_major_version}:{scala-parser-combinators}",
            ],
        )

    maven_install_json_prefix = scala_configuration["maven_install_json_prefix"]

    _maven_install(
        configuration = configuration,
        name = "{repo_prefix}scalac",
        artifacts = [
            "commons-io:commons-io:2.6",
        ],
        maven_install_json = "{maven_install_json_prefix}{repo_prefix}scalac.json" if maven_install_json_prefix else None,
    )

    _maven_install(
        configuration = configuration,
        name = "{repo_prefix}worker",
        artifacts = [
            "com.google.protobuf:protobuf-java:3.11.1",
        ],
        maven_install_json = "{maven_install_json_prefix}{repo_prefix}worker.json" if maven_install_json_prefix else None,
    )

    _maven_install(
        configuration = configuration,
        name = "{repo_prefix}exe",
        artifacts = [
            "com.google.guava:guava:27.1-jre",
        ],
        maven_install_json = "{maven_install_json_prefix}{repo_prefix}exe.json" if maven_install_json_prefix else None,
    )

    default_version = scala_configuration["default"]

    if default_version:
        native.register_toolchains("@io_bazel_rules_scala//scala:scala-%s-toolchain" % default_version)
        native.register_toolchains("@io_bazel_rules_scala//scala:scala-%s-bootstrap-toolchain" % default_version)
        native.register_toolchains("@io_bazel_rules_scala//scala:scala-%s-scalatest-toolchain" % default_version)

def _pinnable_repos():
    pinnable_repos = []

    scala_configuration = _scala_configuration()

    maven_install_json_prefix = scala_configuration["maven_install_json_prefix"]

    if maven_install_json_prefix:
        versions = scala_configuration["scala"]

        for version in versions:
            configuration = _scala_version_configuration(version)

            if configuration["maven_install_json"]:
                pinnable_repos.append(configuration["scala_repo"])

        for target in ["scalac", "worker", "exe"]:
            pinnable_repos.append(configuration["repo_prefix"] + target)

    return pinnable_repos

def pin_targets():
    targets = ["@" + repo + "//:pin" for repo in _pinnable_repos()]

    # print(targets)
    return targets

def unpin_targets():
    return []