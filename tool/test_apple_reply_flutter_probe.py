#!/usr/bin/env python3
"""Check generated probe entitlements without pretending to run macOS WebKit."""
from pathlib import Path
import plistlib
import tempfile
import unittest

from run_apple_reply_flutter_probe import configure_probe_entitlements


class ProbeEntitlementsTest(unittest.TestCase):
    def test_network_client_added_without_removing_template_capabilities(self):
        with tempfile.TemporaryDirectory() as directory:
            app = Path(directory)
            runner = app / 'macos/Runner'
            runner.mkdir(parents=True)
            originals = {
                'DebugProfile.entitlements': {
                    'com.apple.security.app-sandbox': True,
                    'com.apple.security.cs.allow-jit': True,
                    'com.apple.security.network.server': True,
                },
                'Release.entitlements': {
                    'com.apple.security.app-sandbox': True,
                    'custom.preserved.value': 'fixture',
                },
            }
            for name, values in originals.items():
                (runner / name).write_bytes(plistlib.dumps(values))
            configure_probe_entitlements(app)
            first = {name: (runner / name).read_bytes() for name in originals}
            configure_probe_entitlements(app)
            for name, original in originals.items():
                self.assertEqual(
                    plistlib.loads((runner / name).read_bytes()),
                    {**original, 'com.apple.security.network.client': True},
                )
                self.assertEqual((runner / name).read_bytes(), first[name])

    def test_sandbox_cannot_be_disabled_to_make_the_probe_pass(self):
        for sandbox in (None, False):
            with self.subTest(sandbox=sandbox), tempfile.TemporaryDirectory() as directory:
                app = Path(directory)
                runner = app / 'macos/Runner'
                runner.mkdir(parents=True)
                values = {} if sandbox is None else {'com.apple.security.app-sandbox': sandbox}
                for name in ('DebugProfile.entitlements', 'Release.entitlements'):
                    (runner / name).write_bytes(plistlib.dumps(values))
                with self.assertRaisesRegex(RuntimeError, 'must retain App Sandbox'):
                    configure_probe_entitlements(app)


if __name__ == '__main__':
    unittest.main()
