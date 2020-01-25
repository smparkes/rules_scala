load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")

_RULES_JVM_EXTERNAL_TAG = "3.0"

_RULES_JVM_EXTERNAL_SHA = "62133c125bf4109dfd9d2af64830208356ce4ef8b165a6ef15bbff7460b35c3a"

def rules_jvm_external():
    _http_archive(
        name = "rules_jvm_external",
        sha256 = _RULES_JVM_EXTERNAL_SHA,
        strip_prefix = "rules_jvm_external-%s" % _RULES_JVM_EXTERNAL_TAG,
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % _RULES_JVM_EXTERNAL_TAG,
    )
