# Brat OS Bootloader

This directory contains a tiny 16-bit x86 boot sector that shows off some brat vibes in VGA graphics mode.  It switches to mode 13h (320x200x256), blinks a bright green "BRAT MODE \xf0\x9f\xa7\x83\xf0\x9f\x92\x9a" title, draws a hot pink heart in the middle of the screen and then waits for a key.  After a key press it drops back to text mode and prints "okay fine, we back \xf0\x9f\x99\x84".

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

You'll see a blinking "BRAT MODE" banner and a pink heart before it returns to text mode.
