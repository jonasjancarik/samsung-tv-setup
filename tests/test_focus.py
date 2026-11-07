"""Regression checks using the TV's native window format, not its HTTP visible flag."""
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
FREE = ' 2 0x100 7 449 1920 1080 0 0 0 O 24 -1 0 0 1 V 1 DV 0 Free My TV\n'
HIDDEN = FREE.replace(' O ', '   ')
HOME = ' 3 0x200 2 384 1920 1080 0 0 0 O 24 1 2 1 1 V 0 NO 0 /opt/usr/apps/com.samsung.tv.csfs/bin/csfs.dll\n'
NETFLIX = ' 4 0x300 3 600 1920 1080 0 0 0 O 24 -1 0 0 1 V 1 DV 0 Netflix\n'


def parse(text):
    return subprocess.run(['awk', '-f', str(ROOT / 'setup/focus.awk')],
                          input=text, text=True, check=True, capture_output=True).stdout.strip()


class FocusTests(unittest.TestCase):
    def test_real_focused_snapshot(self):
        self.assertEqual(parse((ROOT / 'tests/fixtures/windows-focused.txt').read_text()),
                         '0x012a2288|free')

    def test_running_but_hidden_is_not_success(self):
        self.assertEqual(parse(HIDDEN + HOME), '0x100|home')

    def test_focused_free_my_tv(self):
        self.assertEqual(parse(FREE), '0x100|free')

    def test_another_app_is_distinguished_from_home(self):
        self.assertEqual(parse(HIDDEN + NETFLIX), '0x100|other')

    def test_duplicate_ec_list_cannot_replace_first_list(self):
        self.assertEqual(parse(HIDDEN + HOME + '8 Top level windows in EC list\n' + FREE),
                         '0x100|home')

    def test_no_window_or_focus_yet(self):
        self.assertEqual(parse('Display State: On\n'), '-|none')


if __name__ == '__main__':
    unittest.main()
