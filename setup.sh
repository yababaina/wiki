#!/usr/bin/env bash
set -euo pipefail

echo "=== Wiki 환경 설정 ==="

command -v node >/dev/null || { echo "Node.js가 없습니다. v22+ 설치 후 다시 실행하세요."; exit 1; }
command -v npm >/dev/null || { echo "npm이 없습니다."; exit 1; }
command -v git >/dev/null || { echo "Git이 없습니다."; exit 1; }

nodeMajor=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$nodeMajor" -lt 22 ]; then
  echo "Node v22+ 필요 (현재: $(node -v))"
  exit 1
fi

echo "Node $(node -v), npm $(npm -v)"

echo
echo "[1/3] npm ci ..."
npm ci

echo
echo "[2/3] Quartz 플러그인 설치 ..."
npx quartz plugin install --from-config

echo
echo "[3/3] 빌드 테스트 ..."
npx quartz build

echo
echo "=== 완료 ==="
echo "미리보기:  npx quartz build --serve"
echo "배포:      npx quartz sync"
echo "Obsidian:  content 폴더를 볼트로 열기"
echo "  -> $(pwd)/content"
