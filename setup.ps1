$ErrorActionPreference = "Stop"

Write-Host "=== Wiki 환경 설정 ===" -ForegroundColor Cyan

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js가 없습니다. https://nodejs.org/ (v22+) 설치 후 다시 실행하세요."
}
$nodeMajor = [int](node -v).TrimStart('v').Split('.')[0]
if ($nodeMajor -lt 22) {
    Write-Error "Node v22+ 필요 (현재: $(node -v))"
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "npm이 없습니다."
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git이 없습니다. https://git-scm.com/download/win"
}

Write-Host "Node $(node -v), npm $(npm -v)" -ForegroundColor Green

Write-Host "`n[1/3] npm ci ..." -ForegroundColor Yellow
npm ci

Write-Host "`n[2/3] Quartz 플러그인 설치 ..." -ForegroundColor Yellow
npx quartz plugin install --from-config

Write-Host "`n[3/3] 빌드 테스트 ..." -ForegroundColor Yellow
npx quartz build

Write-Host "`n=== 완료 ===" -ForegroundColor Green
Write-Host "미리보기:  npx quartz build --serve"
Write-Host "배포:      npx quartz sync"
Write-Host "Obsidian:  content 폴더를 볼트로 열기"
Write-Host "  -> $(Join-Path $PWD 'content')"
