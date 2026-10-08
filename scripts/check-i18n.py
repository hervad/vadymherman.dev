#!/usr/bin/env python3
"""Fail if any UI string key exists in one i18n/*.toml file but not in another.

Why: templates call {{ i18n "someKey" }}. If Polish is missing a key, the Polish page
silently shows an empty string. This turns that silent bug into a loud CI failure.
"""
import sys
import tomllib
from pathlib import Path

files = sorted(Path(__file__).resolve().parent.parent.joinpath("i18n").glob("*.toml"))
if len(files) < 2:
    sys.exit(0)

keys = {f.stem: set(tomllib.loads(f.read_text(encoding="utf-8"))) for f in files}
all_keys = set().union(*keys.values())
missing = {lang: sorted(all_keys - k) for lang, k in keys.items() if all_keys - k}

if missing:
    for lang, ks in missing.items():
        print(f"i18n/{lang}.toml is missing: {', '.join(ks)}", file=sys.stderr)
    sys.exit(1)
print(f"i18n OK: {len(all_keys)} keys in {', '.join(keys)}")
