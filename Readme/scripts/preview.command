#!/bin/zsh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$SERVER_ROOT"

PORT=8080
URL="http://127.0.0.1:${PORT}/Readme/index.html"

# 如果 8080 已占用则自动尝试下一个端口
while lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; do
  PORT=$((PORT + 1))
  URL="http://127.0.0.1:${PORT}/Readme/index.html"
done

echo "Starting local server in: $SERVER_ROOT"
echo "URL: $URL"

# 启动服务
python3 -m http.server "$PORT" >/tmp/jp_readme_server.log 2>&1 &
SERVER_PID=$!

# 结束时自动清理后台服务
cleanup() {
  if kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

# 稍等服务启动后打开浏览器
sleep 0.6
open "$URL"

echo "\nServer is running (PID: $SERVER_PID)."
echo "Press Enter to stop server and close this window..."
read -r _
