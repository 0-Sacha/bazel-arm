""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_utilities//toolchains:cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

cc_toolchain_config(
    name = "cc_toolchain_config_%{toolchain_id}",
    toolchain_identifier = "%{toolchain_id}",
    host_name = "%{host_name}",
    target_name = "%{target_name}",
    target_cpu = "%{target_cpu}",
    compiler = {
        "name": "%{arm_toolchain_type}-gcc",
        "base_name": "%{arm_toolchain_type}-",
    },
    toolchain_bins = "//:compiler_components",
    flags = dicts.add(
        %{flags_packed},
        {
            "##linkcopts;copts":  "-no-canonical-prefixes;-fno-canonical-system-headers"
        }
    ),
    cxx_builtin_include_directories = [
        "%{toolchain_path_prefix}%{arm_toolchain_type}/include",
        "%{toolchain_path_prefix}lib/gcc/%{arm_toolchain_type}/%{compiler_version}/include",
        "%{toolchain_path_prefix}lib/gcc/%{arm_toolchain_type}/%{compiler_version}/include-fixed",
        "%{toolchain_path_prefix}%{arm_toolchain_type}/include/c++/%{compiler_version}/",
        "%{toolchain_path_prefix}%{arm_toolchain_type}/include/c++/%{compiler_version}/%{arm_toolchain_type}",
    ],

    copts = %{copts},
    conlyopts = %{conlyopts},
    cxxopts = %{cxxopts},
    linkopts = %{linkopts},
    defines = %{defines},
    includedirs = %{includedirs},
    linkdirs = [
        "%{toolchain_path_prefix}%{arm_toolchain_type}/lib",
        "%{toolchain_path_prefix}lib/gcc/%{arm_toolchain_type}/%{compiler_version}",
    ] + %{linkdirs},
)

cc_toolchain(
    name = "cc_toolchain_%{toolchain_id}",
    toolchain_identifier = "%{toolchain_id}",
    toolchain_config = ":cc_toolchain_config_%{toolchain_id}",
    
    all_files = "//:compiler_pieces",
    compiler_files = "//:compiler_files",
    linker_files = "//:linker_files",
    ar_files = "//:ar",
    as_files = "//:as",
    objcopy_files = "//:objcopy",
    strip_files = "//:strip",
    dwp_files = "//:dwp",
    coverage_files = "//:coverage_files",
    supports_param_files = 0
)

toolchain(
    name = "toolchain_%{toolchain_id}",
    toolchain = ":cc_toolchain_%{toolchain_id}",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",

    target_compatible_with = %{target_compatible_with},
)


filegroup(
    name = "cpp",
    srcs = glob(["bin/%{arm_toolchain_type}-cpp%{extention}"]),
)

filegroup(
    name = "cc",
    srcs = glob(["bin/%{arm_toolchain_type}-gcc%{extention}"]),
)

filegroup(
    name = "cxx",
    srcs = glob(["bin/%{arm_toolchain_type}-g++%{extention}"]),
)

filegroup(
    name = "cov",
    srcs = glob(["bin/%{arm_toolchain_type}-gcov%{extention}"]),
)

filegroup(
    name = "ar",
    srcs = glob(["bin/%{arm_toolchain_type}-ar%{extention}"]),
)

filegroup(
    name = "ld",
    srcs = glob(["bin/%{arm_toolchain_type}-ld%{extention}"]),
)

filegroup(
    name = "nm",
    srcs = glob(["bin/%{arm_toolchain_type}-nm%{extention}"]),
)

filegroup(
    name = "objcopy",
    srcs = glob(["bin/%{arm_toolchain_type}-objcopy%{extention}"]),
)

filegroup(
    name = "objdump",
    srcs = glob(["bin/%{arm_toolchain_type}-objdump%{extention}"]),
)

filegroup(
    name = "strip",
    srcs = glob(["bin/%{arm_toolchain_type}-strip%{extention}"]),
)

filegroup(
    name = "as",
    srcs = glob(["bin/%{arm_toolchain_type}-as%{extention}"]),
)

filegroup(
    name = "size",
    srcs = glob(["bin/%{arm_toolchain_type}-size%{extention}"]),
)

filegroup(
    name = "dwp",
    srcs = glob([]),
)


filegroup(
    name = "compiler_includes",
    srcs = glob([
        "lib/gcc/arm-none-eabi/%{compiler_version}/include/**",
        "lib/gcc/arm-none-eabi/%{compiler_version}/include-fixed/**",
        "arm-none-eabi/include/**",
        "include/**",
    ]),
)

filegroup(
    name = "compiler_libs",
    srcs = glob([
        "lib/gcc/arm-none-eabi/%{compiler_version}/*",
        "arm-none-eabi/lib/*",
        "lib/*",
    ]),
)

filegroup(
    name = "toolchains_bins",
    srcs = glob([
        "bin/**",
        "arm-none-eabi/bin/**",
    ]),
)

filegroup(
    name = "compiler_pieces",
    srcs = [
        ":compiler_includes",
        ":compiler_libs",
    ],
)

filegroup(
    name = "compiler_files",
    srcs = [
        ":compiler_pieces",
        ":cpp",
        ":cc",
        ":cxx",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":compiler_pieces",
        ":cc",
        ":cxx",
        ":ld",
        ":ar",
    ],
)

filegroup(
    name = "coverage_files",
    srcs = [
        ":compiler_pieces",
        ":cc",
        ":cxx",
        ":cov",
        ":ld",
    ],
)

filegroup(
    name = "compiler_components",
    srcs = [
        "cpp",
        "cc",
        "cxx",
        "cov",
        "ar",
        "ld",
        "nm",
        "objcopy",
        "objdump",
        "strip",
        "as",
        "size",
    ],
)


filegroup(
    name = "dbg",
    srcs = glob(["bin/%{arm_toolchain_type}-gdb%{extention}"]),
)

filegroup(
    name = "compiler_extras",
    srcs = [
        "dbg",
    ],
)
