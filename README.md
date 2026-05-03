# Shifty

간호사 및 교대 근무자를 위한 듀티(근무) 스케줄 관리 앱입니다. 캘린더에서 날짜별 근무 유형을 빠르게 입력하고 한눈에 확인할 수 있습니다.

## 주요 기능

- **캘린더 기반 근무 관리** — 월별 캘린더에서 날짜를 선택하고 근무 유형(Day / Evening / Night / Off)을 지정
- **빠른 연속 입력** — 근무 버튼을 누르면 자동으로 다음 날로 이동하여 한 달 스케줄을 빠르게 입력 가능
- **컬러 마커** — 캘린더 위에 근무 유형별 색상 마커 표시 (D:파랑, E:주황, N:보라, O:회색)
- **로컬 알림** — 근무 시작 전 알림 기능 (flutter_local_notifications 기반)
- **오프라인 저장** — Hive를 사용한 로컬 데이터 저장으로 네트워크 없이 동작

## 근무 유형

| 유형 | 약칭 | 시간 | 색상 |
|------|------|------|------|
| Day | D | 07:00 ~ 15:00 (8h) | 파랑 |
| Evening | E | 14:00 ~ 22:00 (8h) | 주황 |
| Night | N | 22:00 ~ 07:00 (9h) | 보라 |
| Off | O | — | 회색 |

## 기술 스택

- **Flutter** (Dart SDK ^3.11.4)
- **Riverpod** — 상태 관리
- **Hive** — 로컬 NoSQL 저장소
- **table_calendar** — 캘린더 UI
- **flutter_local_notifications** — 로컬 푸시 알림
- **timezone / flutter_timezone** — 시간대 처리
- **permission_handler** — 권한 요청

## 프로젝트 구조

```
├── App/                          # Flutter 메인 프로젝트
│   ├── lib/
│   │   ├── main.dart             # 앱 진입점
│   │   ├── models/
│   │   │   ├── shift_type.dart   # 근무 유형 모델 (Day/Evening/Night/Off)
│   │   │   └── duty_entry.dart   # 날짜별 근무 기록 모델
│   │   ├── data/
│   │   │   ├── dummy_data.dart   # 기본 근무 유형 정의 및 테스트 데이터
│   │   │   └── duty_repository.dart  # Hive 기반 데이터 저장소
│   │   ├── providers/
│   │   │   └── shift_providers.dart  # Riverpod 상태 관리
│   │   ├── screens/
│   │   │   ├── home_screen.dart      # 메인 캘린더 화면
│   │   │   └── duty_edit_screen.dart  # 듀티 수정 화면
│   │   └── features/
│   │       └── alarm/
│   │           ├── notification_service.dart  # 알림 서비스 (싱글톤)
│   │           └── dev_alarm_test_screen.dart  # 개발용 알림 테스트
│   ├── android/                  # Android 플랫폼 설정
│   ├── ios/                      # iOS 플랫폼 설정
│   └── pubspec.yaml              # 의존성 정의
└── alarm/                        # 알림 기능 설계 문서 및 프로토타입
```

## 시작하기

```bash
# 의존성 설치
cd App
flutter pub get

# 실행
flutter run
```

## 요구 사항

- Flutter SDK 3.11.4 이상
- Android: minSdkVersion 21, compileSdkVersion 34
- iOS: 지원
