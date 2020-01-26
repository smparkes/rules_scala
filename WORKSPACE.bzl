load(
    "@io_bazel_rules_scala_configuration//:scala_configuration.bzl",
    _scala_configuration = "scala_configuration",
    _scala_version_configuration = "scala_version_configuration",
    _scala_maven_install = "scala_maven_install",
)

def workspace():
    scala_configuration = _scala_configuration()

    versions = scala_configuration["scala"]

    for version in versions:
        configuration = _scala_version_configuration(version)

        _scala_maven_install(
            configuration = configuration,
            name = "{repo_prefix}test",
            artifacts = [
                "com.twitter:scalding-date_{scala_major_version}:0.17.0",
                "org.typelevel:cats-core_{scala_major_version}:0.9.0",
                "org.psywerx.hairyfotr:linter_{scala_major_version}:0.1.13",
                "org.spire-math:kind-projector_{scala_major_version}:0.9.10",
            ],
        )
