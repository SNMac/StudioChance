# SpaceManager
> 공간대여업 점포의 예약을 간편하게 관리하는 크로스플랫폼(iOS, Android) 앱입니다.
>
> [Figma](https://www.figma.com/design/k9iL4QL7DsR93RoyoqHrkU/studio-chance?node-id=0-1&t=cOvS5HBllgn6Uxjm-1)
>
> 개발 기간: 2025.12.10 ~

<br>

## 👥 대상 사용자
- 스튜디오, 연습실, 파티룸 등 공간대여 점포를 운영하는 사람
- 여러 점포를 한 곳에서 관리하고 싶은 사람
- 직원과 함께 예약 현황을 공유하고 싶은 사람

<br><br>

## 🛠️ 기술 스택

|    범위    | 기술 이름                                                                                                            |
| :------: | :--------------------------------------------------------------------------------------------------------------- |
|   아키텍처   | `Clean Architecture`, `MVVM`                                                                                     |
| 디자인 시스템  | `Material 3`                                                                                                     |
|  상태 관리   | `Riverpod` (코드 생성)                                                                                               |
|  네비게이션   | `GoRouter`                                                                                                       |
|  불변 객체   | `Freezed`                                                                                                        |
|  에러 처리   | `fpdart` (Either 패턴)                                                                                             |
| Firebase | `Firestore`, `Authentication`, `Crashlytics`, `Cloud Messaging`, `Analytics`, `App Check`, `Firebase AI(Gemini)` |
|  소셜 로그인  | `Google Sign-In`, `Apple Sign-In`                                                                                |
|  내부 저장소  | `SharedPreferences`                                                                                              |
|    로깅    | `logger`                                                                                                         |
|   테스트    | `flutter_test`, `mocktail`, `fake_cloud_firestore`                                                               |
| 형상 관리 도구 | `Git`, `GitHub`                                                                                                  |

<br><br>

## 🔨 개발 환경

![Static Badge](https://img.shields.io/badge/Dart%203.10.4%20~-%230175C2?logo=dart&logoColor=white)
![Static Badge](https://img.shields.io/badge/Flutter%203.44.1%20~-%2302569B?logo=flutter&logoColor=white)
![Static Badge](https://img.shields.io/badge/iOS%2016.0%20~-%23000000?logo=ios&logoColor=white)
![Static Badge](https://img.shields.io/badge/Android%207.0(API%2024)%20~-%233DDC84?logo=android&logoColor=white)

<br><br>

## 📊 아키텍처

### 레이어 구조

```mermaid
flowchart TD
    subgraph Presentation["Presentation"]
        Screen["Screen"] --> Controller["Controller<br>(Riverpod · AsyncValue)"]
        Screen --> Widget["Widget"]
    end

    subgraph Domain["Domain"]
        UseCaseInterface["UseCase(인터페이스)"]
        UseCaseImpl["UseCase(구현체)"] -->|"구현"| UseCaseInterface
        UseCaseImpl --> RepoInterface["Repository(인터페이스)"]
        UseCaseImpl --> Entity["Entity / Enum"]
    end

    subgraph Data["Data"]
        Repository["RepositoryImpl(구현체)"] -->|"구현"| RepoInterface
        Repository --> DataSource["DataSource(Firebase)"]
    end

    subgraph Common["Common / Constants"]
        Exception["Exception"]
        Converter["Converter"]
    end

    Controller -->|"호출"| UseCaseInterface
    Presentation & Data & Domain -.->|"공통 사용"| Common

    classDef interface fill:#C8E6FA
    class RepoInterface interface
    class UseCaseInterface interface

    style Presentation fill:#EDE7F6,stroke:#B39DDB
    style Domain fill:#E8F5E9,stroke:#A5D6A7
    style Data fill:#FFF3E0,stroke:#FFCC80
    style Common fill:#EEEEEE,stroke:#BDBDBD
```

### 데이터 흐름

```mermaid
flowchart LR
    subgraph Data["Data"]
        DataSource["DataSource<br>(Firebase)"]
        Repository["Repository<br>(Data 로직)"]
    end

    subgraph Domain["Domain"]
        UseCase["UseCase<br>(비즈니스 로직)"]
    end

    subgraph Presentation["Presentation"]
        Controller["Controller<br>(Riverpod)"]
        UI["Screen<br>(UI 이벤트)"]
    end

    DataSource -->|"Model 반환"| Repository
    Repository -->|"Entity 변환 후 반환"| UseCase
    UseCase -->|"결과 반환"| Controller
    Controller -->|"AsyncValue 상태 갱신"| UI

    UI -->|"액션"| Controller
    Controller -->|"호출"| UseCase
    UseCase -->|"Either 반환"| Repository
    Repository -->|"Firebase 호출"| DataSource

    style Data fill:#FFF3E0,stroke:#FFCC80
    style Domain fill:#E8F5E9,stroke:#A5D6A7
    style Presentation fill:#EDE7F6,stroke:#B39DDB
```

---

<br>

## 🗄️ Firestore ERD

### 컬렉션 구조

```
Firestore
├── users/{uid}                                               ← 최상위 컬렉션
│   └── storeById: { [storeId]: UserStoreInfo }               ← 내장 맵
└── stores/{storeId}                                          ← 최상위 컬렉션
    ├── memberById: { [uid]: StoreMemberInfo }                 ← 내장 맵 (승인된 멤버)
    ├── waitingMemberById: { [uid]: StoreMemberInfo }          ← 내장 맵 (가입 대기)
    ├── inviteInfo: InviteInfo?                                ← 내장 객체 (nullable)
    ├── spaceOptions[]: SpaceOption                           ← 내장 배열 (공간 옵션)
    │   └── priceSettings                                      ← 내장 객체 (공간별 요금 설정)
    │       └── dayGroupModels[]: DayGroup                    ← 내장 배열
    │           ├── headcountRuleModel: HeadcountRule          ← 내장 객체
    │           └── timeSlots[]: TimeSlot                     ← 내장 배열
    ├── reservations/{reservationId}                          ← 서브컬렉션
    └── storeCustomers/{customerName}_{phoneNumber}            ← 서브컬렉션
```

### ERD

> **범례**
> - 실선 관계 (`내장`): 동일 문서에 포함된 중첩 객체/맵
> - 점선 참조 (`참조`): 다른 문서의 ID를 키 또는 필드로 저장

```mermaid
erDiagram
    USERS {
        string id PK "uid (doc ID)"
        string email
        string name
        string nickname "nullable"
        array authProviders "List(String)"
        array fcmTokens "List(String) · toJson 제외"
        timestamp createdAt
        timestamp updatedAt
        timestamp lastLoginAt
        timestamp deletedAt "nullable · soft delete"
        timestamp expiresAt "nullable · deletedAt + 7일"
    }

    USER_STORE_INFO {
        string name "점포 표시 이름"
        string role "UserRole enum"
        string color "StoreColor enum"
        string memo
    }

    STORES {
        string id PK "doc ID"
        string name
        string address
        string addressDetail
        string addressGuide
        string bankName "nullable"
        string bankAccountNumber "nullable"
        string bankAccountHolder "nullable"
        int paymentDeadlineMinutes "nullable"
        string infoNotes "nullable"
        string cautionNotes "nullable"
        timestamp createdAt
        timestamp updatedAt
        timestamp deletedAt "nullable · soft delete"
        timestamp expiresAt "nullable · deletedAt + storeSoftDeleteDays"
    }

    MEMBER_INFO {
        string role "UserRole enum · 승인된 멤버"
    }

    WAITING_MEMBER_INFO {
        string role "UserRole enum · 가입 대기 멤버"
    }

    INVITE_INFO {
        string inviteCode "6자리 랜덤 코드"
        timestamp createdAt "유효기간 기준 (15분)"
    }

    SPACE_OPTIONS {
        string id "UUID v4"
        string name "공간 이름"
    }

    DAY_GROUP {
        array days "List(Weekday enum)"
    }

    HEADCOUNT_RULE {
        int headcountBase "기준 인원"
        int headcountExtraPrice "초과 인원당 추가 금액"
        bool isHeadcountHourly "시간당 계산 여부"
        bool isHeadcountPerPerson "1인당 계산 여부"
    }

    TIME_SLOT {
        bool isAllDay "종일 여부"
        int startTime "분 단위"
        int endTime "분 단위"
        int price
        bool isHourly "시간당 계산 여부"
        bool isPerPerson "1인당 계산 여부"
    }

    RESERVATIONS {
        string id PK "doc ID"
        string storeId FK "불변"
        string writerId FK "불변"
        string writerRole "UserRole enum · 불변"
        string status "ReservationStatus enum"
        string customerName
        int headCount
        string customerPhone
        string memo
        bool isAllDay
        timestamp startTime
        timestamp endTime
        string platform "ReservationPlatform enum"
        string paymentMethod "PaymentMethod enum"
        int calculatedPrice
        int priceAdjustment
        int totalPrice
        string spaceOptionId "nullable · 선택된 공간 옵션 ID"
        timestamp createdAt
        timestamp updatedAt
    }

    STORE_CUSTOMERS {
        string id PK "{customerName}_{phoneNumber}"
        string storeId FK
        string name
        string phone
        int totalSpent "FieldValue.increment만 허용"
        int visitCount "FieldValue.increment만 허용"
        timestamp lastReservationDate "예약 startTime 기준"
    }

    USERS ||--o{ USER_STORE_INFO : "storeById[storeId] 내장"
    USER_STORE_INFO }o--|| STORES : "key = storeId 참조"

    STORES ||--o{ MEMBER_INFO : "memberById[uid] 내장"
    MEMBER_INFO }o--|| USERS : "key = uid 참조"

    STORES ||--o{ WAITING_MEMBER_INFO : "waitingMemberById[uid] 내장"
    WAITING_MEMBER_INFO }o--|| USERS : "key = uid 참조"

    STORES ||--o| INVITE_INFO : "inviteInfo 내장"

    STORES ||--o{ SPACE_OPTIONS : "spaceOptions[] 내장"
    SPACE_OPTIONS ||--o{ DAY_GROUP : "priceSettings.dayGroupModels[] 내장"
    DAY_GROUP ||--|| HEADCOUNT_RULE : "headcountRuleModel 내장"
    DAY_GROUP ||--o{ TIME_SLOT : "timeSlots[] 내장"

    STORES ||--o{ RESERVATIONS : "서브컬렉션"
    RESERVATIONS }o--|| USERS : "writerId 참조"
    RESERVATIONS }o--o| SPACE_OPTIONS : "spaceOptionId 참조 (nullable)"

    STORES ||--o{ STORE_CUSTOMERS : "서브컬렉션"
```


---

<br>

## 📱 주요 기능

1. **소셜 로그인**  
   Google 및 Apple 계정으로 간편하게 로그인할 수 있습니다.

<br><br>

2. **3일 캘린더 예약 현황**  
   3일 단위 타임 그리드로 예약 현황을 실시간으로 확인합니다. 종일 예약은 상단 행, 시간대 예약은 해당 시간 셀에 표시되며 Firestore 실시간 구독으로 즉시 반영됩니다.

<br><br>

3. **월간 캘린더**  
   홈 상단의 월간 캘린더로 날짜를 빠르게 이동할 수 있습니다. 날짜를 탭하면 3일 캘린더가 해당 날짜로 이동합니다.

<br><br>

4. **예약 등록 · 수정 · 삭제**  
   고객명, 연락처, 시간, 공간, 결제 방법 등 예약 정보를 입력하고 관리합니다. 점포의 요금 설정에 따라 금액이 자동 계산되며, 메모와 금액 조정도 지원합니다.

<br><br>

5. **예약 스크린샷 OCR (AI 자동 입력)**  
   예약 스크린샷 이미지를 업로드하면 Firebase AI(Gemini)가 고객명, 연락처, 예약 시간을 자동으로 인식해 입력 폼에 채워줍니다.

<br><br>

6. **점포 등록 및 설정**  
   점포 이름, 주소, 계좌 정보, 안내사항 등 기본 정보를 등록합니다. 공간 옵션별로 요일 그룹·시간대·인원 기준을 세분화한 요금 설정을 구성할 수 있습니다.

<br><br>

7. **멤버 초대 및 권한 관리**  
   초대 코드(6자리, 15분 유효)를 생성해 직원·스태프를 초대합니다. 관리자는 가입 대기 멤버를 승인하고 역할(Admin/Staff/Viewer)을 변경할 수 있습니다.

<br><br>

8. **다중 점포 관리**  
   여러 점포를 하나의 앱에서 관리합니다. 점포별 색상으로 구분하고 필터로 원하는 점포의 예약만 표시할 수 있습니다.

<br><br>
