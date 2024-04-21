""

package(default_visibility = ["//visibility:public"])


filegroup(
    name = "cpp",
    srcs = glob(["bin/%{arm_toolchain_type}-cpp%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "cc",
    srcs = glob(["bin/%{arm_toolchain_type}-gcc%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "cxx",
    srcs = glob(["bin/%{arm_toolchain_type}-g++%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "cov",
    srcs = glob(["bin/%{arm_toolchain_type}-gcov%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "ar",
    srcs = glob(["bin/%{arm_toolchain_type}-ar%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "ld",
    srcs = glob(["bin/%{arm_toolchain_type}-ld%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "nm",
    srcs = glob(["bin/%{arm_toolchain_type}-nm%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "objcopy",
    srcs = glob(["bin/%{arm_toolchain_type}-objcopy%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "objdump",
    srcs = glob(["bin/%{arm_toolchain_type}-objdump%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "strip",
    srcs = glob(["bin/%{arm_toolchain_type}-strip%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "as",
    srcs = glob(["bin/%{arm_toolchain_type}-as%{extention}"]), # buildifier: disable=constant-glob
)

filegroup(
    name = "size",
    srcs = glob(["bin/%{arm_toolchain_type}-size%{extention}"]), # buildifier: disable=constant-glob
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
    srcs = glob(["bin/%{arm_toolchain_type}-gdb%{extention}"]),  # buildifier: disable=constant-glob
)

filegroup(
    name = "compiler_extras",
    srcs = [
        "dbg",
    ],
)
