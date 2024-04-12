""

load("@bazel_arm_none_eabi//:archives.bzl", "ARM_NONE_EABI_ARCHIVES_REGISTRY")
load("@bazel_utilities//toolchains:hosts.bzl", "get_host_infos_from_rctx")

def _arm_none_eabi_toolchain_impl(rctx):
    _, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)

    registry = ARM_NONE_EABI_ARCHIVES_REGISTRY[rctx.attr.version]
    compiler_version = registry["details"]["compiler_version"]
    toolchain_id = "arm_none_eabi_{}".format(compiler_version)

    target_compatible_with = []
    target_compatible_with += rctx.attr.target_compatible_with

    flags_packed = {}
    flags_packed.update(rctx.attr.flags_packed)

    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{toolchain_path_prefix}": "external/{}/".format(rctx.name),
        "%{host_name}": host_name,
        "%{toolchain_id}": toolchain_id,
        "%{compiler_version}": compiler_version,

        "%{target_name}": rctx.attr.target_name,
        "%{target_cpu}": rctx.attr.target_cpu,
        "%{target_compatible_with}": json.encode(target_compatible_with),

        "%{copts}": json.encode(rctx.attr.copts),
        "%{conlyopts}": json.encode(rctx.attr.conlyopts),
        "%{cxxopts}": json.encode(rctx.attr.cxxopts),
        "%{linkopts}": json.encode(rctx.attr.linkopts),
        "%{defines}": json.encode(rctx.attr.defines),
        "%{includedirs}": json.encode(rctx.attr.includedirs),
        "%{linkdirs}": json.encode(rctx.attr.linkdirs),

        "%{flags_packed}": json.encode(flags_packed),
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

        'copts': attr.string_list(default = []),
        'conlyopts': attr.string_list(default = []),
        'cxxopts': attr.string_list(default = []),
        'linkopts': attr.string_list(default = []),
        'defines': attr.string_list(default = []),
        'includedirs': attr.string_list(default = []),
        'linkdirs': attr.string_list(default = []),

        'flags_packed': attr.string_dict(default = {}),
    },
    local = False,
    implementation = _arm_none_eabi_toolchain_impl,
)

def arm_none_eabi_toolchain(
        name,
        version = "latest",

        target_name = "local",
        target_cpu = "",
        target_compatible_with = [],

        copts = [],
        conlyopts = [],
        cxxopts = [],
        linkopts = [],
        defines = [],
        includedirs = [],
        linkdirs = [],
        
        flags_packed = {},
    ):
    """arm-none-eabi Toolchain

    This macro create a repository containing all files needded to get an hermetic toolchain

    Args:
        name: Name of the repo that will be created
        version: The arm-none-eabi archive version

        target_name: The target name
        target_cpu: The target cpu name
        target_compatible_with: The target_compatible_with list for the toolchain

        copts: copts
        conlyopts: conlyopts
        cxxopts: cxxopts
        linkopts: linkopts
        defines: defines
        includedirs: includedirs
        linkdirs: linkdirs
        
        flags_packed: pack of flags, checkout the syntax at bazel_utilities
    """
    _arm_none_eabi_toolchain(
        name = name,
        version = version,

        target_name = target_name,
        target_cpu = target_cpu,
        target_compatible_with = target_compatible_with,

        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
        defines = defines,
        includedirs = includedirs,
        linkdirs = linkdirs,

        flags_packed = flags_packed,
    )

    native.register_toolchains("@{}//:toolchain_arm_none_eabi_{}".format(name, ARM_NONE_EABI_ARCHIVES_REGISTRY[version]["details"]["compiler_version"]))
