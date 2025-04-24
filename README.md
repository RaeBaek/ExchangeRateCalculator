# 📱 ExchangeRateCalculator

- 통화 환율 정보를 한눈에 확인할 수 있는 iOS 환율 정보 및 계산기 앱입니다.
- 통화 별 환율 정보로 환율 수치 및 상승, 하락 이미지를 확인할 수 있습니다.
- 선택한 통화로 계산기 화면 진입 시 입력하신 값에 따른 계산된 값을 제공합니다.

---

## 📸 화면 미리보기

<p align="center">
  <img src="https://github.com/user-attachments/assets/efb72ce6-2ead-4606-817c-b4ca87972484" width="79.9%" />
  <img src="https://github.com/user-attachments/assets/7055251b-534d-4bdf-9fc0-15ba6ec8c667" width="18.5%" />
</p>

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

### 1. ✅ UITableViewCell 이미지 및 오토레이아웃 깨짐 현상 해결

<p align="center">
  <img src="https://github.com/user-attachments/assets/fb4bbd3c-f1db-478f-9738-0b93e332a95d" width="48.5%" />
  <img src="https://github.com/user-attachments/assets/f554ab4a-7101-407c-8135-78dd7f68d619" width="49.9%" />
</p>

- **문제**
   - 환율 정보를 표시하는 MainTableViewCell에서 상승/하락 아이콘(upDownImage)이 셀 재사용 시 제약조건이 사라지는 현상 발생
- **원인**
  - 셀 재사용으로 인해 이전 셀의 upDownImage가 재사용됨
  - SnapKit 제약 조건 설정이 불명확해 요소 간 정렬이 흐트러짐
  - 상승/하락 변화가 없는 경우 아이콘이 사라지고 레이아웃이 깨짐
- **해결**
  - prepareForReuse()에서 upDownImage.image = nil로 초기화
  - SnapKit을 통해 exchangeRateLabel, upDownImage, bookmarkButton 간 고정 간격 유지
  - 상승/하락 아이콘이 없을 때도 아이콘 영역 여백을 유지하여 정렬 일관성 확보
  - Debug View Hierarchy를 사용해 뷰 계층 및 간격 문제 디버깅

---

## 🧼 메모리 릭 방지를 위한 RxSwift 사용 전략
### ✅ 문제 인식
- RxSwift를 사용할 때, subscribe, bind 등에서 self를 직접 참조하면 Retain Cycle이 발생하여 메모리 누수로 이어질 수 있음

### ✅ 해결 방식 적용
- RxSwift 연산자에서 항상 약한 참조를 기본으로 습관화
- bind, subscribe에서 withUnretained(self) 또는 with(self)를 사용해 **명시적인 약한 참조** 적용
1. **.withUnretained(self)**
```
input.viewDidLoad
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.exchangeRateUseCase.rxFetchExchangeRateData()
            }
            .withUnretained(self)
            .subscribe { owner, result in
                switch result {
                case .success(let dto):
                    let exchangeRate = dto.toDomain()
                    owner.currencyUpdateUseCase.updateCurrencyData(with: exchangeRate)
                    rates.accept(exchangeRate)
                case .failure(let error):
                    errorMessage.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
```
2. **.subscribe(with: self)**
```
input.bookmarkButtonTapped
            .withLatestFrom(filteredRates) { indexPath, models in
                return (indexPath, models)
            }
            .subscribe(with: self) { owner, pair in
                let (indexPath, models) = pair
                filteredRates.accept(owner.handleBookmarkToggle(at: indexPath, in: models))
            }
            .disposed(by: disposeBag)
```
### ✅ 경험 결과
- Instruments의 Leaks 도구를 통해 실행 중 메모리 릭 발생 여부를 점검한 결과, 누수 없음 확인
- UILabel, UIImageView, ViewController 등 재사용 대상들도 Transient 객체로 분류되어 적절히 해제되고 있음 확인

---

## 💦 메모리 이슈 디버깅 및 경험
### 메모리 누수가 발견되지는 않았지만 Instruments - Leaks 사용 경험
- Xcode Menu - Product - Profile
- Instruments - Leaks
- Recording Button Click

<p align="center">
  <img src="https://github.com/user-attachments/assets/8fe38e24-5421-4f99-b6c5-e65a55700a1a" width="100%" />
</p>

---
