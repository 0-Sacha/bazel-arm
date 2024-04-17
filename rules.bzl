""

load("@bazel-arm//:archives.bzl", "ARM_REGISTRY")
load("@bazel-utilities//toolchains:hosts.bzl", "get_host_infos_from_rctx")

def _get_registry(toolchain_type, toolchain_version):
    if toolchain_type not in ARM_REGISTRY:
        # buildifier: disable=print
        print("bazel-arm doesn't support arm toolchain type: {}".format(toolchain_type))
        if toolchain_version not in ARM_REGISTRY[toolchain_type]:
            # buildifier: disable=print
            print("{} toolchain doesn't define version: {}".format(toolchain_type, toolchain_version))
    return ARM_REGISTRY[toolchain_type][toolchain_version]

def _arm_toolchain_impl(rctx):
    _, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)

    check_version(rctx.attr.arm_toolchain_type, rctx.attr.arm_toolchain_version)

    registry = _get_registry(rctx.attr.arm_toolchain_type, rctx.attr.arm_toolchain_version)
    compiler_version = registry["details"]["compiler_version"]
    toolchain_id = "{}_{}".format(rctx.attr.arm_toolchain_type, compiler_version)

    target_compatible_with = []
    target_compatible_with += rctx.attr.target_compatible_with

    flags_packed = {}
    flags_packed.update(rctx.attr.flags_packed)

    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{toolchain_path_prefix}": "external/{}/".format(rctx.name),
        "%{host_name}": host_name,
        "%{toolchain_id}": toolchain_id,
        "%{arm_toolchain_type}": rctx.attr.arm_toolchain_type,
        "%{arm_toolchain_version}": rctx.attr.arm_toolchain_version,
        "%{compiler_version}": compiler_version

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

_arm_toolchain = repository_rule(
    attrs = {
        'arm_toolchain_type': attr.string(mandatory = True),
        'arm_toolchain_version': attr.string(default = "latest"),

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
    implementation = _arm_toolchain_impl,
)

def arm_toolchain(
        name,
        arm_toolchain_type,
        arm_toolchain_version = "latest",

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
    """arm Toolchain

    This macro create a repository containing all files needded to get an hermetic toolchain

    Args:
        name: Name of the repo that will be created
        arm_toolchain_type: The arm type to use, avaible: [ arm-none-eabi ]
        arm_toolchain_version: The arm archive version

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
        
        flags_packed: pack of flags, checkout the syntax at bazel-utilities
    """
    _arm_toolchain(
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

    registry = _get_registry(arm_toolchain_type, arm_toolchain_version)
    native.register_toolchains("@{}//:toolchain_{}_{}".format(name, rctx.attr.arm_toolchain_type, registry["details"]["compiler_version"]))
