# SpaceManager
> 공간대여업 점포의 예약을 간편하게 관리하는 크로스플랫폼(iOS, Android) 앱입니다.
>
> [Figma](https://www.figma.com/design/k9iL4QL7DsR93RoyoqHrkU/studio-chance?node-id=0-1&t=cOvS5HBllgn6Uxjm-1)
>
> 개발 기간: 2026.12.10 ~

<br>

## 👥 대상 사용자
- 스튜디오, 연습실, 파티룸 등 공간대여 점포를 운영하는 사람
- 여러 점포를 한 곳에서 관리하고 싶은 사람
- 직원과 함께 예약 현황을 공유하고 싶은 사람

<br><br>

## 🛠️ 기술 스택

|      범위       | 기술 이름                                                                                                |
| :-------------: | :------------------------------------------------------------------------------------------------------- |
|  의존성 관리 도구  | `pub.dev`                                                                                                |
|   형상 관리 도구   | `Git`, `GitHub`                                                                                          |
|    아키텍처     | `Clean Architecture`, `MVVM`                                                                             |
|   디자인 시스템   | `Material 3`                                                                                             |
|    상태 관리    | `Riverpod` (코드 생성)                                                                                    |
|    네비게이션    | `GoRouter`                                                                                               |
|    불변 객체    | `Freezed`                                                                                                |
|    에러 처리    | `fpdart` (Either 패턴)                                                                                    |
|    Firebase    | `Firestore`, `Authentication`, `Crashlytics`, `Cloud Messaging`, `Analytics`, `App Check`               |
|   소셜 로그인    | `Google Sign-In`, `Apple Sign-In`                                                                        |
|   내부 저장소    | `SharedPreferences`                                                                                      |
|      로깅       | `logger`                                                                                                 |
|      테스트      | `flutter_test`, `mocktail`                                                                               |

<br><br>

## 🔨 개발 환경

![Static Badge](https://img.shields.io/badge/Dart%203.10.4%20~-%230175C2?logo=dart&logoColor=white)
![Static Badge](https://img.shields.io/badge/Flutter%203.38.5%20~-%2302569B?logo=flutter&logoColor=white)
![Static Badge](https://img.shields.io/badge/iOS%2016.0%20~-%23000000?logo=ios&logoColor=white)
![Static Badge](https://img.shields.io/badge/Android%2024%20~-%233DDC84?logo=android&logoColor=white)

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
        UseCase["UseCase"] --> RepoInterface["Repository(인터페이스)"]
        UseCase --> Entity["Entity / Enum"]
    end

    subgraph Data["Data"]
        Repository["RepositoryImpl(구현체)"] -->|"구현"| RepoInterface
        Repository --> DataSource["DataSource(Firebase)"]
    end

    subgraph Common["Common / Constants"]
        Exception["Exception"]
        Converter["Converter"]
    end

    Controller -->|"호출"| UseCase
    Presentation & Data & Domain -.->|"공통 사용"| Common
```

### 데이터 흐름

```mermaid
flowchart LR
    UI["Screen<br>(UI 이벤트)"]
    Controller["Controller<br>(Riverpod)"]
    UseCase["UseCase<br>(비즈니스 로직)"]
    Repository["Repository<br>(Data 로직)"]
    DataSource["DataSource<br>(Firebase)"]

    UI -->|"액션"| Controller
    Controller -->|"Either 반환"| UseCase
    UseCase -->|"Either 반환"| Repository
    Repository -->|"Firebase 호출"| DataSource
    DataSource -->|"Model 반환"| Repository
    Repository -->|"Entity 변환 후 반환"| UseCase
    UseCase -->|"결과 반환"| Controller
    Controller -->|"AsyncValue 상태 갱신"| UI
```

---

<br>

## 🗄️ Firestore ERD

### 컬렉션 구조

```
Firestore
├── users/{uid}                                          ← 최상위 컬렉션
│   └── storeById: { [storeId]: UserStoreInfo }          ← 내장 맵
└── stores/{storeId}                                     ← 최상위 컬렉션
    ├── memberById: { [uid]: StoreMemberInfo }            ← 내장 맵 (승인된 멤버)
    ├── waitingMemberById: { [uid]: StoreMemberInfo }     ← 내장 맵 (가입 대기)
    ├── inviteInfo: InviteInfo?                           ← 내장 객체 (nullable)
    ├── priceSettings                                     ← 내장 객체
    │   └── dayGroups[]: DayGroup                        ← 내장 배열
    │       ├── headcountRule: HeadcountRule              ← 내장 객체
    │       └── timeSlots[]: TimeSlot                    ← 내장 배열
    ├── reservations/{reservationId}                     ← 서브컬렉션
    └── storeCustomers/{customerName}_{phoneNumber}       ← 서브컬렉션
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

    STORES ||--o{ DAY_GROUP : "priceSettings.dayGroups[] 내장"
    DAY_GROUP ||--|| HEADCOUNT_RULE : "headcountRule 내장"
    DAY_GROUP ||--o{ TIME_SLOT : "timeSlots[] 내장"

    STORES ||--o{ RESERVATIONS : "서브컬렉션"
    RESERVATIONS }o--|| USERS : "writerId 참조"

    STORES ||--o{ STORE_CUSTOMERS : "서브컬렉션"
```

---

<br>

## 👨‍💻 트러블 슈팅

### (트러블슈팅 제목)

#### 문제 상황

#### 원인 분석

#### 해결 과정

---

<br>

## 📱 주요 기능

1. **기능 제목**
   > 기능 설명

<br><br>
