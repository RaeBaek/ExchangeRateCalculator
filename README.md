# 📱 ExchangeRateCalculator

<!-- 내용을 작성해주세요. -->

---

## 📸 화면 미리보기

<!-- 내용을 작성해주세요. -->

---

## 🗓 프로젝트 일정

- **시작일:** 2025년 4월 14일
- **종료일:** 2025년 4월 24일

---

## 📂 폴더 구조
```
ExchangeRateCalculator
├── App/                 # 앱 전역에서 사용되는 설정 관련 디렉토리
│   └── DI/                 # 의존성 주입에 필요한 객체 생성 및 주입을 관리
├── Domain/              # 비즈니스 로직의 중심이 되는 계층, 외부와의 의존이 없는 순수 로직 정의
│   ├── Model/              # 도메인에서 사용하는 결과 타입, 에러 타입 등 순수 모델 정의
│   ├── Entity/             # 앱에서 핵심이 되는 도메인 엔티티 정의
│   ├── Repository/         # Repository의 인터페이스 정의
│   └── UseCase/            # 앱의 기능 단위를 정의하는 비즈니스 로직 인터페이스
├── Data                 # 외부 데이터 소스와의 연결 및 구체적인 비즈니스 로직 구현 담당   
│   ├── DTO/                # 네트워크 통신 시 주고받는 데이터 포맷 정의
│   ├── Repository/         # Domain에 정의된 Repository 프로토콜의 실제 구현체
│   ├── UseCase/            # Domain에 정의된 UseCase의 실제 구현체
│   ├── Service/            # API 호출, CoreData 접근 등 외부 서비스와의 연동 처리
│   └── CoreData/           # CoreData 관련 클래스, 속성 정의 파일 관리
├── Presentation         # UI와 관련된 로직을 관리하는 계층
│   ├── Shared/
│   │   ├── Constants/      # 앱 전역에서 사용되는 상수값 정의
│   │   ├── Extension/      # UIKit 컴포넌트 등에 대한 기능 확장
│   │   └── Protocol/       # 공통적으로 사용되는 프로토콜 정의
│   └── Base/               # 공통으로 사용되는 기본 ViewController, View 등 정의
│   └── MVVM/
│       ├── View/           # 화면에 보여지는 View 클래스들
│       │   └── Cell/       # TableView, CollectionView 등 Cell 관련 클래스
│       ├── ViewController/ # 각 화면의 ViewController
│       └── ViewModel/      # 비즈니스 로직을 처리하는 ViewModel
└── Resources/           # 프로젝트의 리소스를 관리하는 디렉토리
```

---

## 🛠 사용 기술

- **Swift 5**
- **UIKit**
- **MVVM Pattern**
- **Clean Architecture**
- **Core Data**
- **RxSwift & RxCocoa**
- **SnapKit**
- **Then**
- **Dependency Injection**

---

## 🌟 주요 기능

- Open API를 통한 실시간 환율 정보 확인 가능
- 통화 검색 기능 제공 (통화 코드, 통화명)
- 관심있는 통화를 즐겨찾기 기능으로 상단 고정
- 어제와 오늘의 환율을 비교하여 상승, 하락 이미지 표시
- 환율 계산기 화면을 통해 원하는 통화 환율 계산 가능
- 다크모드 제공
- 사용자가 마지막으로 본 화면부터 앱 재시작

---

## 🧩 Trouble Shooting

<!-- 내용을 작성해주세요. -->

---
