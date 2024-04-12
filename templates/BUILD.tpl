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
        "name": "arm-none-eabi-gcc",
        "base_name": "arm-none-eabi-",
    },
    toolchain_bins = "//:compiler_components",
    flags = dicts.add(
        %{flags_packed},
        {
            "##linkcopts;copts":  "-no-canonical-prefixes;-fno-canonical-system-headers"
        }
    ),
    cxx_builtin_include_directories = [
        "%{toolchain_path_prefix}arm-none-eabi/include",
        "%{toolchain_path_prefix}lib/gcc/arm-none-eabi/{compiler_version}/include",
        "%{toolchain_path_prefix}lib/gcc/arm-none-eabi/{compiler_version}/include-fixed",
        "%{toolchain_path_prefix}arm-none-eabi/include/c++/{compiler_version}/",
        "%{toolchain_path_prefix}arm-none-eabi/include/c++/{compiler_version}/arm-none-eabi",
    ],

    copts = %{copts},
    conlyopts = %{conlyopts},
    cxxopts = %{cxxopts},
    linkopts = %{linkopts},
    defines = %{defines},
    includedirs = %{includedirs},
    linkdirs = [
        "%{toolchain_path_prefix}arm-none-eabi/lib",
        "%{toolchain_path_prefix}lib/gcc/arm-none-eabi/{compiler_version}",
    ] + %{linkdirs},
)

cc_toolchain(
    name = "cc_toolchain_%{toolchain_id}",
    toolchain_identifier = "%{toolchain_id}",
    toolchain_config = "cc_toolchain_config_%{toolchain_id}",
    
    all_files = "//:compiler_artfacts",
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
    toolchain = "cc_toolchain_%{toolchain_id}",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",

    target_compatible_with = %{target_compatible_with},
)


filegroup(
    name = "cpp",
    srcs = glob(["bin/arm-none-eabi-cpp*"]),
)

filegroup(
    name = "cc",
    srcs = glob(["bin/arm-none-eabi-gcc*"]),
)

filegroup(
    name = "cxx",
    srcs = glob(["bin/arm-none-eabi-g++*"]),
)

filegroup(
    name = "cov",
    srcs = glob(["bin/arm-none-eabi-gcov*"]),
)

filegroup(
    name = "ar",
    srcs = glob(["bin/arm-none-eabi-ar*"]),
)

filegroup(
    name = "ld",
    srcs = glob(["bin/arm-none-eabi-ld*"]),
)

filegroup(
    name = "nm",
    srcs = glob(["bin/arm-none-eabi-nm*"]),
)

filegroup(
    name = "objcopy",
    srcs = glob(["bin/arm-none-eabi-objcopy*"]),
)

filegroup(
    name = "objdump",
    srcs = glob(["bin/arm-none-eabi-objdump*"]),
)

filegroup(
    name = "strip",
    srcs = glob(["bin/arm-none-eabi-strip*"]),
)

filegroup(
    name = "as",
    srcs = glob(["bin/arm-none-eabi-as*"]),
)

filegroup(
    name = "size",
    srcs = glob(["bin/arm-none-eabi-size*"]),
)

filegroup(
    name = "dwp",
    srcs = glob([]),
)


filegroup(
    name = "compiler_artfacts",
    srcs = glob([
        "arm-none-eabi/**",
        "lib/gcc/arm-none-eabi/{compiler_version}/**",
        'arm-none-eabi/include/c++/{compiler_version}/**',
    ]),
)

filegroup(
    name = "compiler_files",
    srcs = [
        ":compiler_artfacts",
        ":cpp",
        ":cc",
        ":cxx",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":compiler_artfacts",
        ":cc",
        ":cxx",
        ":ld",
        ":ar",
    ],
)

filegroup(
    name = "coverage_files",
    srcs = [
        ":compiler_artfacts",
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
    srcs = glob(["bin/arm-none-eabi-gdb*"]),
)

filegroup(
    name = "compiler_extras",
    srcs = [
        "dbg",
    ],
)
