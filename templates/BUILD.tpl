""
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
    flags = {
        "##linkcopts;copts":  "-no-canonical-prefixes;-fno-canonical-system-headers"
    },
    cxx_builtin_include_directories = [
        "%{toolchain_path_prefix}arm-none-eabi/include",
        "%{toolchain_path_prefix}lib/gcc/arm-none-eabi/{compiler_version}/include",
        "%{toolchain_path_prefix}lib/gcc/arm-none-eabi/{compiler_version}/include-fixed",
        "%{toolchain_path_prefix}arm-none-eabi/include/c++/{compiler_version}/",
        "%{toolchain_path_prefix}arm-none-eabi/include/c++/{compiler_version}/arm-none-eabi",
    ],
    lib_directories = [
        "%{toolchain_path_prefix}arm-none-eabi/lib",
        "%{toolchain_path_prefix}lib/gcc/arm-none-eabi/{compiler_version}",
    ]
)

cc_toolchain(
    name = "cc_toolchain_%{toolchain_id}",
    toolchain_identifier = "%{toolchain_id}",
    toolchain_config = "cc_toolchain_config_%{toolchain_id}",
    
    all_files = "//:compiler_pieces",
    ar_files = "//:ar",
    compiler_files = "//:compiler_files",
    dwp_files = "//:dwp",
    linker_files = "//:linker_files",
    objcopy_files = "//:objcopy",
    strip_files = "//:strip",
    supports_param_files = 0
)

toolchain(
    name = "toolchain_%{toolchain_id}",
    toolchain = "cc_toolchain_%{toolchain_id}",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",

    target_compatible_with = json.decode("%{target_compatible_with_packed}"),
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
    name = "cpp",
    srcs = glob(["bin/arm-none-eabi-cpp*"]),
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
    name = "compiler_pieces",
    srcs = glob([
        "arm-none-eabi/**",
        "lib/gcc/arm-none-eabi/**",
        'arm-none-eabi/include/**',
        'libexec/**',
    ]),
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
    name = "compiler_components",
    srcs = [
        "cc",
        "cxx",
        "cpp",
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
