# memory
SynthLAN is a synthwave-themed network monitor that plays different
sound loops based on network activity. It is designed to run on a
Raspberry Pi but also works on desktop systems.

## Usage

```bash
python3 SynthLAN.py --low 1024 --medium 10240 --high 51200
```

The script expects WAV files in the `assets` directory. Because binary
files are not stored in the repository, each sample is provided as a
`[filename].wav.txt` file containing base64 data. Convert these text
files back into `.wav` files before running SynthLAN. Use the
`--no-audio` option if no audio device is available or you only want to
see the terminal meter.
