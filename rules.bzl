""

load("@bazel_arm//:archives.bzl", "ARM_REGISTRY")
load("@bazel_utilities//toolchains:archives.bzl", "get_archive_from_registry")
load("@bazel_utilities//toolchains:hosts.bzl", "get_host_infos_from_rctx", "HOST_EXTENTION")

def _arm_compiler_archive_impl(rctx):
    host_os, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)
    
    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{rctx_path}": "external/{}/".format(rctx.name),
        "%{extention}": HOST_EXTENTION[host_os],
        "%{host_name}": host_name,
        "%{arm_toolchain_type}": rctx.attr.arm_toolchain_type,
        "%{arm_toolchain_version}": rctx.attr.arm_toolchain_version,
        "%{compiler_version}": rctx.attr.compiler_version,
    }
    rctx.template(
        "BUILD",
        Label("//templates:BUILD.compiler.tpl"),
        substitutions
    )

    archives = json.decode(rctx.attr.archives)
    archive = archives[host_name]

    rctx.download_and_extract(
        url = archive["url"],
        sha256 = archive["sha256"],
        stripPrefix = archive["strip_prefix"],
    )

arm_compiler_archive = repository_rule(
    implementation = _arm_compiler_archive_impl,
    attrs = {
        'arm_toolchain_type': attr.string(mandatory = True),
        'arm_toolchain_version': attr.string(default = "latest"),
        'compiler_version': attr.string(mandatory = True),
        'archives': attr.string(mandatory = True),
    },
    local = False,
)


def _arm_toolchain_impl(rctx):
    host_os, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)

    toolchain_id = "{}_{}".format(rctx.attr.arm_toolchain_type, compiler_version)

    target_compatible_with = []
    target_compatible_with += rctx.attr.target_compatible_with

    flags_packed = {}
    flags_packed.update(rctx.attr.flags_packed)

    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{rctx_path}": "external/{}/".format(rctx.name),
        "%{extention}": HOST_EXTENTION[host_os],
        "%{host_name}": host_name,
        "%{toolchain_id}": toolchain_id,
        "%{arm_toolchain_type}": rctx.attr.arm_toolchain_type,
        "%{arm_toolchain_version}": rctx.attr.arm_toolchain_version,
        "%{compiler_version}": rctx.attr.compiler_version,
        "%{compiler_package}": "@{}//".format(rctx.attr.compiler_package) if rctx.attr.compiler_package != "" else "",
        "%{compiler_package_path}": "external/{}/".format(rctx.attr.compiler_package),

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
    rctx.template(
        "vscode.bzl",
        Label("//templates:vscode.bzl.tpl"),
        substitutions
    )

    archives = json.decode(rctx.attr.archives)
    archive = archives[host_name]

    if rctx.attr.local_download:
        rctx.download_and_extract(
            url = archive["url"],
            sha256 = archive["sha256"],
            stripPrefix = archive["strip_prefix"],
        )

_arm_toolchain = repository_rule(
    implementation = _arm_toolchain_impl,
    attrs = {
        'arm_toolchain_type': attr.string(mandatory = True),
        'arm_toolchain_version': attr.string(default = "latest"),
        'compiler_version': attr.string(mandatory = True),

        'local_download': attr.bool(default = True),
        'archives': attr.string(mandatory = True),
        'compiler_package': attr.string(default = "//"),

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

        local_download = True,
        registry = ARM_REGISTRY,
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
        
        flags_packed: pack of flags, checkout the syntax at bazel_utilities

        local_download: wether the archive should be downloaded in the same repository (True) or in its own repo
        registry: The arm registry to use, to allow close environement to provide their own mirroir/url
    """
    compiler_package = ""

    archive = get_archive_from_registry(registry, arm_toolchain_type, arm_toolchain_version)

    if local_download == False:
        compiler_package = "{}_{}".format(arm_toolchain_type, arm_toolchain_version)
        arm_compiler_archive(
            name = compiler_package,
            arm_toolchain_type = arm_toolchain_type,
            arm_toolchain_version = arm_toolchain_version,
            compiler_version = archive["details"]["compiler_version"],
            archives = json.encode(archive["archives"]),
        )

    _arm_toolchain(
        name = name,
        arm_toolchain_type = arm_toolchain_type,
        arm_toolchain_version = arm_toolchain_version,
        compiler_version = archive["details"]["compiler_version"],

        local_download = local_download,
        archives = json.encode(archive["archives"]),
        compiler_package = compiler_package,

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

    native.register_toolchains("@{}//:toolchain_{}_{}".format(name, arm_toolchain_type, archive["details"]["compiler_version"]))
