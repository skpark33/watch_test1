# 디지털 시계 앱 아키텍처 설계

## 1. 개요

본 문서는 디지털 시계 앱의 기술 아키텍처를 정의합니다. 요구사항을 충족하고, 유지보수성, 확장성, 테스트 용이성을 확보하기 위해 **클린 아키텍처(Clean Architecture)**를 채택합니다.

아키텍처는 크게 **Presentation, Domain, Data** 세 개의 계층으로 구성됩니다.

### 아키텍처 다이어그램

아래 다이어그램은 계층 간의 의존성 규칙을 보여줍니다. 화살표는 의존성 방향을 나타내며, 모든 의존성은 외부에서 내부로 향합니다. 즉, UI와 데이터 소스는 비즈니스 로직에 의존하지만, 비즈니스 로직은 외부에 대해 알지 못합니다.

```mermaid
graph TD
    subgraph Presentation Layer
        direction LR
        A[UI (Widgets)] --> B(State Management<br>Riverpod)
    end

    subgraph Domain Layer
        direction LR
        C[Use Cases] --> D[Entities]
        C --> E[Repository Interfaces]
    end

    subgraph Data Layer
        direction LR
        F[Repository Implementations] --> G[Data Sources<br>Local / TimeZone]
    end

    B --> C
    F -- implements --> E
```

## 2. 계층별 상세 설명

### 2.1. Domain Layer (도메인 계층)

- **역할**: 앱의 핵심 비즈니스 로직을 포함합니다. 이 계층은 다른 어떤 계층에도 의존하지 않는 순수한 Dart 코드로 작성됩니다.
- **구성 요소**:
    - **Entities**: 비즈니스 객체를 정의합니다. (예: `Alarm`, `ClockSettings`, `WorldCity`)
    - **Repository Interfaces**: 데이터 계층에서 구현해야 할 데이터 처리 규칙(추상 클래스)을 정의합니다. (예: `AlarmRepository`, `SettingsRepository`)
    - **Use Cases (Interactors)**: 특정 기능에 대한 비즈니스 로직을 캡슐화합니다. (예: `GetTimeStream`, `SaveAlarm`, `AddWorldCity`)

### 2.2. Data Layer (데이터 계층)

- **역할**: 도메인 계층의 Repository Interface를 구현하며, 데이터의 출처(로컬 DB, 네트워크 등)를 책임집니다.
- **구성 요소**:
    - **Repository Implementations**: 도메인 계층의 추상 Repository를 구체적으로 구현합니다.
    - **Data Sources**: 데이터의 원천을 관리합니다.
        - **Local Data Source**: `shared_preferences` 또는 `Hive`와 같은 로컬 저장소를 사용하여 알람, 설정, 세계 시각 도시 목록을 저장하고 불러옵니다.
        - **Time Data Source**: `DateTime`과 `Timer`를 사용하여 현재 시간을 제공하고, 타임존 데이터를 처리하여 세계 시간을 제공합니다.
    - **Models**: 데이터 소스로부터 데이터를 주고받기 위한 데이터 전송 객체(DTO)입니다. `fromJson`, `toJson`과 같은 직렬화/역직렬화 로직을 포함할 수 있습니다.

### 2.3. Presentation Layer (프레젠테이션 계층)

- **역할**: UI와 상태 관리를 담당합니다. 사용자의 입력을 받아 처리하고, 변경된 상태를 화면에 표시합니다.
- **구성 요소**:
    - **UI (Widgets)**: Flutter 위젯을 사용하여 화면을 구성합니다. (예: `ClockPage`, `AlarmSettingsView`, `FlipDigit`)
    - **State Management**: UI의 상태를 관리하고, 도메인 계층의 Use Case를 호출하여 비즈니스 로직을 실행합니다. **Riverpod**를 사용하여 상태를 효율적으로 관리하고 의존성을 주입합니다.
        - **Providers/Notifiers**: 각 기능별 상태(예: `ClockState`, `AlarmState`)를 관리하고 UI에 변경 사항을 알립니다.

## 3. 디렉터리 구조

프로젝트의 구조는 기능별로 모듈을 나누는 **Feature-First** 방식을 따릅니다. 각 기능은 자신만의 Domain, Data, Presentation 계층을 갖습니다.

```
lib/
├── main.dart
│
├── core/
│   ├── di/                 # 의존성 주입 (Dependency Injection) 설정
│   ├── theme/              # 앱 전체 테마 (라이트/다크)
│   ├── constants/          # 공통 상수
│   └── error/              # 공통 에러 및 예외 처리
│
└── features/
    ├── clock/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── notifiers/    # Riverpod Notifiers
    │       ├── pages/
    │       └── widgets/      # 해당 기능 전용 위젯
    │
    ├── alarm/
    │   └── ... (clock과 동일한 구조)
    │
    ├── world_clock/
    │   └── ... (clock과 동일한 구조)
    │
    └── settings/
        └── ... (clock과 동일한 구조)
``` 