# 디지털 시계 앱 개발 체크리스트 (TODO)

이 문서는 디지털 시계 앱 개발의 전체 작업 순서와 각 단계별 완료 기준을 정의합니다. 각 항목 완료 후에는 명시된 커밋 메시지로 버전을 관리합니다.

---

### ☐ **Phase 1: 프로젝트 설정 및 기본 구조 수립**
- [ ] `flutter create watch` 명령어로 Flutter 프로젝트 생성
- [ ] `docs/architecture.md`에 정의된 디렉터리 구조 생성 (core, features, 각 기능별 폴더)
- [ ] `pubspec.yaml`에 필요한 기본 라이브러리 추가 (flutter_riverpod, shared_preferences 등)
- [ ] 기본 `main.dart` 설정 및 Riverpod `ProviderScope` 적용
- [ ] 라이트/다크 모드를 위한 기본 테마 파일 생성 (`core/theme/`)
- **COMMIT**: `feat: Initial project setup and directory structure`

---

### ☐ **Phase 2: 핵심 기능 - 시계 표시 구현**
- [ ] **Domain**:
    - [ ] `ClockSettings` 엔티티 정의 (시간 형식 등)
    - [ ] `GetTimeStream` 유스케이스 작성 (현재 시간을 Stream으로 제공)
- [ ] **Data**:
    - [ ] 시스템 시간(`DateTime`)을 사용하는 `TimeDataSource` 구현
- [ ] **Presentation**:
    - [ ] 플립 애니메이션을 위한 `FlipDigit` 위젯 프로토타입 제작
    - [ ] `ClockPage` UI 레이아웃 구성 (와이어프레임 기반)
    - [ ] Riverpod `StreamProvider`를 사용하여 시간 스트림을 UI에 연결
    - [ ] 날짜 및 요일 표시 기능 구현
- [ ] **Test**:
    - [ ] `GetTimeStream` 유스케이스 유닛 테스트 작성
    - [ ] `FlipDigit` 위젯 테스트 작성
- **COMMIT**: `feat(clock): Implement real-time clock display with flip animation`

---

### ☑ **Phase 3: 설정 기능 구현**
- [x] **Domain**:
    - [x] `SettingsRepository` 인터페이스 및 `ClockSettings` 엔티티 확장
    - [x] `GetSettings`, `SaveSettings` 유스케이스 작성
- [x] **Data**:
    - [x] `shared_preferences`를 사용한 `SettingsRepository` 구현
- [x] **Presentation**:
    - [x] 12/24시간제 토글 버튼 UI 및 기능 구현
    - [x] 라이트/다크 모드 테마 토글 버튼 UI 및 기능 구현
    - [x] 설정 변경 시 UI가 즉시 반영되도록 Riverpod `StateNotifier` 연결
- [x] **Test**:
    - [x] `SaveSettings` 유스케이스 유닛 테스트 작성
    - [x] 설정 토글 위젯 기능 테스트
- **COMMIT**: `feat(settings): Implement theme and time format toggle`

---

### ☐ **Phase 4: 세계 시각 기능 구현**
- [ ] **Domain**:
    - [ ] `WorldCity` 엔티티 및 `WorldClockRepository` 인터페이스 정의
    - [ ] `GetWorldCities`, `AddWorldCity`, `DeleteWorldCity` 유스케이스 작성
- [ ] **Data**:
    - [ ] `shared_preferences`를 사용한 `WorldClockRepository` 구현
    - [ ] 타임존 계산을 위한 로직 구현 (또는 라이브러리 활용)
- [ ] **Presentation**:
    - [ ] 기본 시계 ↔ 세계 시각 화면 전환 기능 구현
    - [ ] `WorldClockPage` UI 구성 (와이어프레임 기반)
    - [ ] 도시 추가/관리 UI 및 기능 구현
- [ ] **Test**:
    - [ ] 세계 시각 관련 유스케이스 유닛 테스트 작성
- **COMMIT**: `feat(worldclock): Implement world clock view and city management`

---

### ☐ **Phase 5: 알람 기능 구현**
- [ ] **Domain**:
    - [ ] `Alarm` 엔티티 및 `AlarmRepository` 인터페이스 정의
    - [ ] `GetAlarm`, `SaveAlarm`, `EnableAlarm` 유스케이스 작성
- [ ] **Data**:
    - [ ] `shared_preferences`를 사용한 `AlarmRepository` 구현
    - [ ] 알람 시간에 알림을 발생시키는 로직 구현 (`flutter_local_notifications` 활용)
    - [ ] 사용자 오디오 파일을 선택하는 로직 구현 (`file_picker` 활용)
- [ ] **Presentation**:
    - [ ] `AlarmSettingsPage` UI 구성 (시간, 반복, 스누즈, 소리 설정)
    - [ ] 알람 설정 및 활성화/비활성화 기능 구현
- [ ] **Test**:
    - [ ] 알람 설정/저장 로직 유닛 테스트
- **COMMIT**: `feat(alarm): Implement alarm setting and notification`

---

### ☐ **Phase 6: 최종 검토 및 빌드**
- [ ] 반응형 레이아웃 최종 점검 (다양한 창 크기에서 테스트)
- [ ] 코드 린팅(Linting) 및 정적 분석을 통한 코드 품질 개선
- [ ] 각 플랫폼(Web, Android, Windows) 빌드 테스트 및 최적화
- [ ] 최종 사용자 관점에서의 앱 테스트
- **COMMIT**: `refactor: Finalize app and prepare for release` 