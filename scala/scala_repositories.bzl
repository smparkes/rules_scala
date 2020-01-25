load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
)
load("@rules_jvm_external//:defs.bzl", _maven_install = "maven_install")
load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")

def scala_repositories():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:

        configuration = _scala_version_configuration(version)

        _maven_install(
            name = configuration["scala_repo"],
            artifacts = [
                "org.scala-lang:scala-compiler:{scala_version}".format(**configuration),
                "org.scala-lang:scala-library:{scala_version}".format(**configuration), #
                "org.scala-lang:scala-reflect:{scala_version}".format(**configuration),
                "org.scalatest:scalatest_{scala_major_version}:{scalatest}".format(**configuration),
                "org.scalactic:scalactic_{scala_major_version}:{scalatest}".format(**configuration),
                "org.scala-lang.modules:scala-xml_{scala_major_version}:{scala-xml}".format(**configuration),
                "org.scala-lang.modules:scala-parser-combinators_{scala_major_version}:{scala-parser-combinators}".format(**configuration),
            ],
            repositories = configuration["repositories"],
            version_conflict_policy = configuration["version_conflict_policy"],
            maven_install_json = configuration["maven_install_json"],
        )

    repo_prefix = scala_configuration["repo_prefix"]
    repositories = scala_configuration["repositories"]
    version_conflict_policy = scala_configuration["version_conflict_policy"]
    maven_install_json_prefix = scala_configuration["maven_install_json_prefix"]

    print(repo_prefix + "scalac")

    _maven_install(
        name = repo_prefix + "scalac",
        artifacts = [
            "commons-io:commons-io:2.6",
        ],
        repositories = repositories,
        version_conflict_policy = version_conflict_policy,
        maven_install_json = maven_install_json_prefix + "scalac" + ".json" if maven_install_json_prefix else None
    )

    _maven_install(
        name = repo_prefix + "worker",
        artifacts = [
            "com.google.protobuf:protobuf-java:3.11.1",
        ],
        repositories = repositories,
        version_conflict_policy = version_conflict_policy,
        maven_install_json = maven_install_json_prefix + "worker" + ".json" if maven_install_json_prefix else None
    )

    _maven_install(
        name = repo_prefix + "exe",
        artifacts = [
            "com.google.guava:guava:27.1-jre",
        ],
        repositories = repositories,
        version_conflict_policy = version_conflict_policy,
        maven_install_json = maven_install_json_prefix + "exe" + ".json" if maven_install_json_prefix else None
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
    print(targets)
    return targets

def unpin_targets():
    return []
