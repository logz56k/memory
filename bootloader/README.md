# Brat OS Bootloader

This directory contains a minimal 16-bit x86 boot sector that prints a brat-themed welcome message and waits for the user to type **`vroom`**. If the input matches, a success message is shown; otherwise it asks again.

## Building

Use NASM to assemble the boot sector.  The compiled binary is not tracked in
the repository, so you'll need to build it yourself:

```bash
nasm -f bin brat_boot.asm -o brat_boot.bin
```

The resulting `brat_boot.bin` file is exactly 512 bytes and includes the required boot signature.

## Running

You can test the bootloader with an emulator such as QEMU:

```bash
qemu-system-i386 -fda brat_boot.bin
```

It will display the welcome text in bright green and prompt for input.
