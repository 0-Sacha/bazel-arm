""

load("@rules_cc//cc:defs.bzl", "cc_binary")

def _arm_none_eabi_all_files_impl(ctx):
    # buildifier: disable=print
    print("Copy '{}' to '{}'".format(ctx.file.binary, ctx.outputs.elf))
    ctx.actions.run(
        inputs = [ ctx.file.binary ],
        outputs = [ ctx.outputs.elf ],
        executable = "cp",
        arguments = [
            ctx.file.binary.path,
            ctx.outputs.elf.path
        ],
    )

    # buildifier: disable=print
    print("Create bin file '{}' from '{}'".format(ctx.outputs.bin, ctx.file.binary))
    ctx.actions.run(
        inputs = [ ctx.file.binary ],
        outputs = [ ctx.outputs.bin ],
        executable = ctx.file.objcopy.path,
        arguments = [
            "-O",
            "binary",
            "-S",
            ctx.file.binary.path,
            ctx.outputs.bin.path
        ],
    )

    # buildifier: disable=print
    print("Create hex file '{}' from '{}'".format(ctx.outputs.hex, ctx.file.binary))
    ctx.actions.run(
        inputs = [ ctx.file.binary ],
        outputs = [ ctx.outputs.hex ],
        executable = ctx.file.objcopy.path,
        arguments = [
            "-O",
            "ihex",
            ctx.file.binary.path,
            ctx.outputs.hex.path
        ],
    )

arm_none_eabi_all_files = rule(
    implementation = _arm_none_eabi_all_files_impl,
    attrs = {
        'objcopy': attr.label(allow_single_file = True),
        "binary": attr.label(allow_single_file = True),
        "elf": attr.output(),
        "bin": attr.output(),
        "hex": attr.output(),
    },
)

def arm_none_eabi_binary(name, arm_file_elf = None, arm_file_bin = None, arm_file_hex = None, **kwargs):
    """arm_none_eabi_binary macro

    Args:
        name: The binary name
        arm_file_elf: The output elf file name
        arm_file_bin: The output bin file name
        arm_file_hex: The output hex file name
        **kwargs: All others cc_binary attributes
    """
    binary_rule_name = "{}_raw_binary".format(name)
    cc_binary(name = binary_rule_name, **kwargs)
    arm_none_eabi_all_files(
        name = name,
        objcopy = "@%{rctx_name}//:objcopy",
        binary = ":{}".format(binary_rule_name),
        elf = "{}.elf".format(name) if arm_file_elf == None else arm_file_elf,
        bin = "{}.bin".format(name) if arm_file_bin == None else arm_file_bin,
        hex = "{}.hex".format(name) if arm_file_hex == None else arm_file_hex
    )
