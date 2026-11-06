#!/usr/bin/env python3
"""Build/run the live macOS WebKit + Flutter probe using this checkout.

Creates an isolated temporary Flutter app. No signing identity or application
pins are changed. JSON reports contain real round-trip timings and Dart counts;
they intentionally do not claim native allocations, CPU, or device results.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, default=Path('apple-reply-results.json'))
args = parser.parse_args()
if sys.platform != 'darwin':
    parser.error('the live probe requires macOS, Xcode, and Flutter; no simulated pass is reported')
flutter = shutil.which('flutter')
if not flutter:
    parser.error('flutter must be on PATH')
with tempfile.TemporaryDirectory(prefix='apple-reply-flutter-') as directory:
    app = Path(directory) / 'apple_reply_probe'
    subprocess.run([flutter, 'create', '--platforms=macos', '--project-name=apple_reply_probe', '--no-pub', str(app)], check=True)
    template = ROOT / 'tool/apple_reply_probe'
    shutil.copy2(template / 'lib/main.dart', app / 'lib/main.dart')
    (app / 'pubspec.yaml').write_text((template / 'pubspec.yaml').read_text().replace('../../flutter_inappwebview', str(ROOT / 'flutter_inappwebview')))
    (app / 'assets').mkdir()
    shutil.copy2(ROOT / 'tool/javascript_handler_json_cases.json', app / 'assets/javascript_handler_json_cases.json')
    subprocess.run([flutter, 'pub', 'get'], cwd=app, check=True)
    subprocess.run([flutter, 'analyze', 'lib/main.dart'], cwd=app, check=True)
    subprocess.run([flutter, 'build', 'macos', '--release'], cwd=app, check=True)
    executable = app / 'build/macos/Build/Products/Release/apple_reply_probe.app/Contents/MacOS/apple_reply_probe'
    process = subprocess.run([str(executable)], cwd=app, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=420)
    print(process.stdout)
    if process.returncode:
        raise SystemExit(process.returncode)
    tag = 'APPLE_REPLY_RESULT:'
    rows = [line.split(tag, 1)[1] for line in process.stdout.splitlines() if tag in line]
    if len(rows) != 1:
        raise RuntimeError('probe did not produce exactly one success report')
    report = json.loads(rows[0])
    report['commit'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    report['buildMode'] = 'release'
    report['flutter'] = json.loads(subprocess.check_output([flutter, '--version', '--machine'], text=True))
    report['runner'] = {'ci': os.environ.get('CI') == 'true', 'architecture': os.uname().machine}
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(f'Live Apple reply probe passed; report: {args.output}')
