# memory
SynthLAN is a synthwave-themed network monitor that plays different
sound loops based on network activity. It is designed to run on a
Raspberry Pi but also works on desktop systems.

## Usage

```bash
python3 SynthLAN.py --low 1024 --medium 10240 --high 51200
```

Place MP3 files in the `assets` directory with the following names:
`low.mp3`, `medium.mp3`, `high.mp3`, and `error.mp3`. Binary media is not
tracked, so add your own tracks before running SynthLAN. Use the
`--no-audio` option if no audio device is available or you only want to
see the terminal meter. Network levels are averaged over the last ten
seconds so songs change based on sustained trends rather than instant
spikes.
