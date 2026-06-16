# 새 PC에서 wiki 세팅

## 사전 설치

- [Git](https://git-scm.com/download/win)
- [Node.js 22+](https://nodejs.org/) (`.node-version` 참고)
- (선택) [Obsidian](https://obsidian.md/)

## 클론 & 환경 구성

```powershell
git clone https://github.com/yababaina/wiki.git
cd wiki
Set-ExecutionPolicy -Scope Process Bypass
.\setup.ps1
```

Mac/Linux:

```bash
git clone https://github.com/yababaina/wiki.git
cd wiki
chmod +x setup.sh
./setup.sh
```

또는 npm 스크립트만 사용:

```powershell
npm run setup
npx quartz build
```

## Obsidian

1. Obsidian 실행
2. **Open folder as vault**
3. `wiki/content` 폴더 선택

## 일상 사용

| 명령 | 설명 |
|------|------|
| `npx quartz sync` | 변경사항 commit + push → GitHub Pages 자동 배포 |
| `npx quartz build --serve` | 로컬 미리보기 (`http://localhost:8080`) |
| `npm run dev` | 위와 동일 |
| `npm run sync` | `npx quartz sync` 와 동일 |

## GitHub 인증 (새 PC 최초 1회)

첫 `npx quartz sync` 시 브라우저 로그인 창이 뜹니다.  
또는 GitHub CLI:

```powershell
gh auth login
```

이후 해당 PC에서는 자격 증명이 저장되어 매번 로그인할 필요 없습니다.

## 사이트 주소

https://yababaina.github.io/wiki/
