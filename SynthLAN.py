import os
import time
import argparse
import psutil
import pygame

# SynthLAN: an audio-driven network feedback system
# Inspired by the synthwave aesthetic of Com Truise

class SynthLAN:
    """Monitor network traffic and respond with synth sounds."""
    def __init__(self, assets_dir='assets',
                 low_thresh=1024,
                 med_thresh=10240,
                 high_thresh=51200,
                 enable_audio=True):
        self.assets_dir = assets_dir
        self.audio_enabled = enable_audio
        self.thresholds = {
            'low': low_thresh,
            'medium': med_thresh,
            'high': high_thresh
        }
        self._load_assets()
        self.current_level = None
        self.channel = None
        self.prev_total = 0

    def _load_sound(self, name):
        path = os.path.join(self.assets_dir, name)
        if not os.path.exists(path):
            print(f"[SynthLAN] Missing sound: {path}")
            return None
        return pygame.mixer.Sound(path)

    def _load_assets(self):
        if not self.audio_enabled:
            self.sounds = {}
            return
        try:
            pygame.mixer.init()
        except pygame.error as exc:
            print(f"[SynthLAN] Audio init failed: {exc}. Running muted.")
            self.audio_enabled = False
            self.sounds = {}
            return
        self.sounds = {
            'low': self._load_sound('low_traffic.wav'),
            'medium': self._load_sound('medium_traffic.wav'),
            'high': self._load_sound('high_traffic.wav'),
            'error': self._load_sound('error.wav')
        }

    def _play_loop(self, level):
        if not self.audio_enabled:
            self.current_level = level
            return
        if self.current_level == level:
            return
        if self.channel:
            self.channel.stop()
        snd = self.sounds.get(level)
        if snd:
            self.channel = snd.play(loops=-1)
        self.current_level = level

    def _play_once(self, key):
        if not self.audio_enabled:
            return
        snd = self.sounds.get(key)
        if snd:
            snd.play()

    def _meter_bar(self, value, width=30):
        max_val = self.thresholds['high']
        val = min(value, max_val)
        filled = int((val / max_val) * width)
        return '[' + '#' * filled + '-' * (width - filled) + ']'

    def monitor(self):
        print("SynthLAN starting... Ctrl+C to stop")
        prev = psutil.net_io_counters()
        try:
            while True:
                time.sleep(1)
                curr = psutil.net_io_counters()
                sent = curr.bytes_sent - prev.bytes_sent
                recv = curr.bytes_recv - prev.bytes_recv
                total = sent + recv
                prev = curr

                if total <= self.thresholds['low']:
                    level = 'low'
                elif total <= self.thresholds['medium']:
                    level = 'medium'
                else:
                    level = 'high'

                self._play_loop(level)

                # Detect spikes or drops
                if self.prev_total and (
                    total == 0 or total > self.prev_total * 5
                ):
                    self._play_once('error')
                self.prev_total = total

                bar = self._meter_bar(total)
                print(f"Traffic: {total:8d} B/s {bar} level: {level}   ", end='\r')
        except KeyboardInterrupt:
            print("\nStopping SynthLAN...")
        finally:
            if self.audio_enabled:
                pygame.mixer.quit()


def parse_args():
    p = argparse.ArgumentParser(description="SynthLAN - synthwave network feedback")
    p.add_argument('--assets', default='assets', help='Path to assets folder with wav files')
    p.add_argument('--low', type=int, default=1024, help='Threshold for low traffic (bytes/s)')
    p.add_argument('--medium', type=int, default=10240, help='Threshold for medium traffic')
    p.add_argument('--high', type=int, default=51200, help='Threshold for high traffic')
    p.add_argument('--no-audio', action='store_true', help='Run without playing sounds')
    return p.parse_args()

if __name__ == '__main__':
    args = parse_args()
    synthlan = SynthLAN(assets_dir=args.assets,
                        low_thresh=args.low,
                        med_thresh=args.medium,
                        high_thresh=args.high,
                        enable_audio=not args.no_audio)
    synthlan.monitor()

# --- Placeholders for future expansions ---
# def midi_out(note):
#     """Send MIDI note to external hardware."""
#     pass
#
# def led_sync(level):
#     """Sync LED strip colors with current network level."""
#     pass
#
# def websocket_trigger(data):
#     """Send network data to websocket clients."""
#     pass
