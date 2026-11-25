#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Verify every animal sound + image URL in lib/data/animals.dart.

Checks each non-empty soundUrl (HTTP 200, audio content-type, size > 2KB)
and each imageUrl (HTTP 200, image content-type), and asserts the data rules:
- exactly 100 animals, unique Arabic names
- no shared generic sound file (animal_bark_and_growl must be gone)
- every animal either has a real sound or an explicitly empty soundUrl
- guessable == False for every animal without a sound

Usage: python3 tool/verify_animal_media.py [--write-log]
Writes tool/verify_animal_media.log when --write-log is given.
Exit code 0 only if every check passes.
"""
import re
import sys
import urllib.request
import concurrent.futures
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'lib' / 'data' / 'animals.dart'
LOG = Path(__file__).resolve().parent / 'verify_animal_media.log'

HEADERS = {'User-Agent': 'FaresAnimalsDataBot/1.0 (media verification)'}


def check_url(url):
    """Return (status, content_type, size). Follows the HEAD->GET-range fallback."""
    req = urllib.request.Request(url, method='HEAD', headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status, r.headers.get('Content-Type', ''), r.headers.get('Content-Length', '')
    except Exception:
        req = urllib.request.Request(
            url, headers={**HEADERS, 'Range': 'bytes=0-1023'})
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status, r.headers.get('Content-Type', ''), r.headers.get('Content-Length', '')


def main():
    txt = SRC.read_text(encoding='utf-8')
    entries = re.findall(r"^  Animal\((.*?)\)", txt, re.S | re.M)
    animals = []
    for e in entries:
        f = dict(re.findall(r"(\w+): '([^']*)'", e))
        # guessable is an explicit named arg only when False (default True)
        f['guessable'] = 'guessable: false' not in e
        animals.append(f)

    problems = []
    lines = []
    if len(animals) != 100:
        problems.append(f'animal count is {len(animals)}, expected 100')
    names = [a['nameAr'] for a in animals]
    if len(set(names)) != 100:
        problems.append('duplicate Arabic names')
    if 'animal_bark_and_growl' in txt:
        problems.append('animal_bark_and_growl.ogg is still linked somewhere')
    shared = [u for u, c in Counter(
        a['soundUrl'] for a in animals if a['soundUrl']).items() if c > 1]
    # dog_barking.ogg is knowingly shared by Dog + Husky (both dogs)
    unexpected_shared = [u for u in shared if 'dog_barking' not in u]
    if unexpected_shared:
        problems.append(f'unexpected shared sound urls: {unexpected_shared}')
    for a in animals:
        if not a['soundUrl'] and a['guessable']:
            problems.append(f"{a['nameAr']} has no sound but guessable=true")
        if a['soundUrl'] and not a['soundUrl'].startswith('http'):
            problems.append(f"{a['nameAr']} soundUrl is not http(s)")

    jobs = []
    for a in animals:
        if a['soundUrl']:
            jobs.append(('sound', a['nameAr'], a['soundUrl']))
        jobs.append(('image', a['nameAr'], a['imageUrl']))

    def run(job):
        kind, name, url = job
        try:
            status, ctype, size = check_url(url)
        except Exception as exc:  # noqa: BLE001 - report, don't crash
            return kind, name, url, 0, '', str(exc)[:100]
        return kind, name, url, status, ctype, size

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as ex:
        results = list(ex.map(run, jobs))

    ok_sounds = ok_images = 0
    for kind, name, url, status, ctype, size in sorted(results):
        n = int(size) if str(size).isdigit() else 0
        if kind == 'sound':
            # Wikimedia serves Ogg as application/ogg; SoundBible/Google as audio/*
            good = status == 200 and ('audio' in ctype or 'ogg' in ctype) and n > 2048
            ok_sounds += good
            if not good:
                problems.append(f'sound FAIL {name}: {status} {ctype} {size} {url}')
        else:
            good = status == 200 and 'image' in ctype
            ok_images += good
            if not good:
                problems.append(f'image FAIL {name}: {status} {ctype} {size} {url}')
        lines.append(f"{'OK  ' if good else 'FAIL'} {kind:5} {name} | {status} | {ctype} | {size} | {url}")

    with_sound = sum(1 for a in animals if a['soundUrl'])
    summary = (f"animals=100 with_sound={with_sound} silent={100 - with_sound} "
               f"sounds_ok={ok_sounds}/{with_sound} images_ok={ok_images}/100 "
               f"categories={dict(Counter(a['category'] for a in animals))}")
    lines.append(summary)
    report = '\n'.join(lines)
    print(report)
    if '--write-log' in sys.argv:
        LOG.write_text(report + '\n', encoding='utf-8')
        print(f'log written to {LOG}')
    if problems:
        print('\nPROBLEMS:')
        for p in problems:
            print(' -', p)
        return 1
    print('\nAll checks passed.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
