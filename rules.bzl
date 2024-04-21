""

load("@bazel_mingw//:archives.bzl", "ARM_NONE_EABI_ARCHIVES_REGISTRY")
load("@bazel_utilities//toolchains:hosts.bzl", "get_host_infos_from_rctx")

def _arm_none_eabi_impl(rctx):
    _, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)

    registry = ARM_NONE_EABI_ARCHIVES_REGISTRY[rctx.attr.mingw_version]
    compiler_version = registry["details"]["compiler_version"]
    toolchain_id = "arm_none_eabi_{}".format(compiler_version)

    constraints = []
    constraints += rctx.attr.target_compatible_with

    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{host_name}": host_name,
        "%{target_name}": rctx.attr.target_name,
        "%{target_cpu}": rctx.attr.target_cpu,
        "%{toolchain_path_prefix}": "external/{}/".format(rctx.name),
        
        "%{toolchain_id}": toolchain_id,
        "%{compiler_version}": compiler_version,
        
        "%{target_compatible_with_packed}": json.encode(constraints).replace("\"", "\\\""),
    }
    rctx.template(
        "BUILD",
        Label("//templates:BUILD.tpl"),
        substitutions
    )
    rctx.template(
        "rules.bzl",
        Label("//templates:rules.bzl.tpl"),
        substitutions
    )

    archive = registry["archives"][host_name]
    rctx.download_and_extract(archive["url"], sha256 = archive["sha256"], stripPrefix = archive["strip_prefix"])

_arm_none_eabi_toolchain = repository_rule(
    attrs = {
        'version': attr.string(default = "latest"),

        'target_name': attr.string(default = "local"),
        'target_cpu': attr.string(default = ""),

        'target_compatible_with': attr.string_list(default = []),
    },
    local = False,
    implementation = _arm_none_eabi_impl,
)

def arm_none_eabi_toolchain(
    name,
    version = "latest",
    target_name = "local",
    target_cpu = "",
    target_compatible_with = []
    ):
    """arm-none-eabi Toolchain

    This macro create a repository containing all files needded to get an hermetic toolchain

    Args:
        name: Name of the repo that will be created
        version: The arm-none-eabi archive version
        target_name: The target name
        target_cpu: The target cpu name
        target_compatible_with: The target_compatible_with list for the toolchain
    """
    _arm_none_eabi_toolchain(
        name = name,
        version = version,
        target_name = target_name,
        target_cpu = target_cpu,
        target_compatible_with = target_compatible_with
    )

    native.register_toolchains("@{}//:toolchain_arm_none_eabi_{}".format(name, ARM_NONE_EABI_ARCHIVES_REGISTRY[version]["details"]["compiler_version"]))
