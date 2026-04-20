#!/bin/zsh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

ROOT_DIR="$ROOT_DIR" python3 - <<'PY'
import os
import json
from pathlib import Path

root = Path(os.environ["ROOT_DIR"])
readme = (root / 'README_EN.md').read_text(encoding='utf-8')
out = 'window.__README_MD__ = ' + json.dumps(readme, ensure_ascii=False) + ';\n'
(root / 'docs' / 'js' / 'readme_en_resource.js').write_text(out, encoding='utf-8')
print('Updated docs/js/readme_en_resource.js from README_EN.md')
PY
