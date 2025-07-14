# Brat OS Bootloader

This directory contains a minimal 16-bit x86 boot sector that starts a tiny shell named `XCXSH` in real mode. After booting it displays a prompt and waits for brat-themed commands.

Available commands:
- `yeet`  → prints `file yeeted 💅`
- `vroom` → enters a short "rave" effect that blinks the screen
- `drama` → prints dramatic tears
- `charli` → prints a lyric from "Vroom Vroom"
- `cry`   → exit the shell

Unknown commands get a playful error message.

## Building

Use NASM to assemble the boot sector. The binary is not tracked in the repo so build it yourself:

```bash
nasm -f bin brat_boot.asm -o brat_boot.bin
```

`brat_boot.bin` will be exactly 512 bytes with the required boot signature.

## Running

Test the bootloader with an emulator such as QEMU:

```bash
qemu-system-i386 -fda brat_boot.bin
```

You'll see the `XCXSH >` prompt. Type the commands above to interact, and `cry` to stop.
