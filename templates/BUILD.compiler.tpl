""

package(default_visibility = ["//visibility:public"])


filegroup(
    name = "cpp",
    srcs = ["bin/%{arm_toolchain_type}-cpp%{extention}"],
)
filegroup(
    name = "cc",
    srcs = ["bin/%{arm_toolchain_type}-gcc%{extention}"],
)
filegroup(
    name = "cxx",
    srcs = ["bin/%{arm_toolchain_type}-g++%{extention}"],
)
filegroup(
    name = "as",
    srcs = ["bin/%{arm_toolchain_type}-as%{extention}"],
)
filegroup(
    name = "ar",
    srcs = ["bin/%{arm_toolchain_type}-ar%{extention}"],
)
filegroup(
    name = "ld",
    srcs = ["bin/%{arm_toolchain_type}-ld%{extention}"],
)

filegroup(
    name = "objcopy",
    srcs = ["bin/%{arm_toolchain_type}-objcopy%{extention}"],
)
filegroup(
    name = "strip",
    srcs = ["bin/%{arm_toolchain_type}-strip%{extention}"],
)

filegroup(
    name = "cov",
    srcs = ["bin/%{arm_toolchain_type}-gcov%{extention}"],
)

filegroup(
    name = "size",
    srcs = ["bin/%{arm_toolchain_type}-size%{extention}"],
)
filegroup(
    name = "nm",
    srcs = ["bin/%{arm_toolchain_type}-nm%{extention}"],
)
filegroup(
    name = "objdump",
    srcs = ["bin/%{arm_toolchain_type}-objdump%{extention}"],
)
filegroup(
    name = "dwp",
    srcs = ["bin/%{arm_toolchain_type}-dwp%{extention}"],
)

filegroup(
    name = "dbg",
    srcs = ["bin/%{arm_toolchain_type}-gdb%{extention}"],
)

filegroup(
    name = "toolchain_includes",
    srcs = glob([
        "lib/gcc/arm-none-eabi/%{compiler_version}/include/**",
        "lib/gcc/arm-none-eabi/%{compiler_version}/include-fixed/**",
        "arm-none-eabi/include/**",
        "include/**",
    ]),
)

filegroup(
    name = "toolchain_libs",
    srcs = glob([
        "lib/gcc/arm-none-eabi/%{compiler_version}/*",
        "arm-none-eabi/lib/*",
        "lib/*",
    ]),
)

filegroup(
    name = "toolchains_bins",
    srcs = glob([
        "bin/*%{extention}",
        "arm-none-eabi/bin/*%{extention}",
    ]),
)

filegroup(
    name = "all_files",
    srcs = [
        ":toolchain_includes",
        ":toolchain_libs",
        ":toolchain_bins",
    ],
)

filegroup(
    name = "compiler_files",
    srcs = [
        ":toolchain_includes",
        ":cpp",
        ":cc",
        ":cxx",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":toolchain_libs",
        ":cc",
        ":cxx",
        ":ld",
        ":ar",
    ],
)

filegroup(
    name = "coverage_files",
    srcs = [
        ":toolchain_includes",
        ":toolchain_libs",
        ":cc",
        ":cxx",
        ":ld",
        ":cov",
    ],
)

filegroup(
    name = "compiler_components",
    srcs = [
        ":cpp",
        ":cc",
        ":cxx",
        ":ar",
        ":ld",

        ":objcopy",
        ":strip",

        ":cov",

        ":nm",
        ":objdump",
        ":as",
        ":size",
        ":dwp",
        
        ":dbg",
    ],
)
