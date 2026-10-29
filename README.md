# MoSS-iOS

학생들을 위한 차분하고 조용한 공부 명소, **MoSS** iOS 앱

## 개발 환경
- Xcode 16 이상 / iOS 17.0+
- SwiftUI · MVVM
- 코드는 VS Code, 빌드·실행은 Xcode

> 프로젝트는 Xcode 16의 **폴더 동기화(Synchronized Folder)** 방식이에요.
> `MoSS/` 아래에 파일을 추가하면 Xcode 프로젝트에 자동으로 포함되니 VS Code에서 바로 파일을 만들어도 돼요.

## 폰트 설정 (Gothic A1)
폰트 파일은 레포에 포함되어 있지 않아요. 아래 파일을 받아 `MoSS/Resources/Font/`에 넣으면 자동 등록됩니다. (없으면 시스템 폰트로 대체)

- [Google Fonts - Gothic A1](https://fonts.google.com/specimen/Gothic+A1)
- 필요한 굵기: `Regular` `Medium` `SemiBold` `Bold` `ExtraBold` `Black` (`GothicA1-*.ttf`)

## 서버 주소
`MoSS/Core/Network/APIConfig.swift`의 `baseURL`을 수정하세요.

## 폴더 구조
```
MoSS
├── App            # 앱 진입점, RootView
├── Core
│   ├── Network    # Endpoint, NetworkService, API별 Service
│   ├── Session    # 로그인 상태 관리
│   ├── Storage    # Keychain, 토큰 저장
│   ├── Theme      # 색상, 폰트, 레이아웃 상수
│   └── Util
├── Model
├── View
│   ├── Common     # 공통 컴포넌트
│   ├── Auth
│   ├── Main
│   ├── Place
│   ├── Review
│   ├── User
│   └── Owner
├── ViewModel
└── Resources
    ├── Asset      # Assets.xcassets
    └── Font
```

## 컨벤션
- Branch: `main` / `develop` / `feature/기능명` / `fix/기능명` / `refactor/기능명`
- Commit: `type: 내용` (feat, fix, design, refactor, docs, chore)
- PR 제목: `[Feat] 리뷰 작성 기능 추가`
