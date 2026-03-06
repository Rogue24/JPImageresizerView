#!/bin/zsh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

ROOT_DIR="$ROOT_DIR" python3 - <<'PY'
import os
import json
from pathlib import Path

root = Path(os.environ["ROOT_DIR"])
readme = (root / 'README.md').read_text(encoding='utf-8')
out = 'window.__README_MD__ = ' + json.dumps(readme, ensure_ascii=False) + ';\n'
(root / 'Readme' / 'js' / 'readme_resource.js').write_text(out, encoding='utf-8')
print('Updated Readme/js/readme_resource.js from README.md')
PY
