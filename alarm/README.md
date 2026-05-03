# Alarm 최소 기능 (듀티 데이터와 완전 분리)

버튼을 누르면 1분 뒤 로컬 알림이 뜨는 최소 단위. 듀티 관련 코드(`ShiftType`, `DutyEntry`, `DutyRepository`)는 건드리지 않는다.

## 파일

- `notification_service.dart` — 싱글톤 서비스. `initialize / requestPermissions / scheduleOneShot / cancel / getPending`
- `dev_alarm_test_screen.dart` — 개발용 화면. `DevAlarmTestScreen.isAvailable`이 `kDebugMode`일 때만 true

프로젝트에 편입할 때는 `App/lib/features/alarm/` 등으로 이동시켜 쓰면 된다.

## 1. pubspec.yaml

```yaml
dependencies:
  flutter_local_notifications: ^17.2.3
  timezone: ^0.9.4
  flutter_timezone: ^3.0.1
  permission_handler: ^11.3.1
```

> `flutter_native_timezone`은 deprecated라 `flutter_timezone`을 사용.

## 2. Android 설정

### `android/app/src/main/AndroidManifest.xml`

`<manifest>` 바로 아래, `<application>` 바깥에 권한 추가:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

`<application>` 내부에 receiver 추가:

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
  </intent-filter>
</receiver>
```

### `android/app/build.gradle` (또는 `build.gradle.kts`)

`flutter_local_notifications`는 core library desugaring이 필수다:

```groovy
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        multiDexEnabled true
    }
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
```

## 3. 사용 예

`main()`에서 `WidgetsFlutterBinding.ensureInitialized()` 이후 한 번 호출:

```dart
await NotificationService.instance.initialize();
```

라우팅에서 debug 모드만 노출:

```dart
if (DevAlarmTestScreen.isAvailable)
  DevAlarmTestScreen.routeName: (_) => const DevAlarmTestScreen(),
```

## 4. 검증 체크리스트

- [ ] 포그라운드에서 버튼 → 1분 뒤 알림
- [ ] 백그라운드 상태에서도 알림
- [ ] 앱 완전 종료 후에도 알림 ★
- [ ] 권한 거부 시 스낵바 안내 표시
- [ ] `getPending()`에 1개 조회됨

## 주의

- `tz.initializeTimeZones()` + `tz.setLocalLocation()`을 반드시 `zonedSchedule` 이전에. 빠지면 UTC 기준으로 동작해 KST 9시간 어긋남.
- Android 12+는 `SCHEDULE_EXACT_ALARM`을 사용자가 시스템 설정에서 직접 허용해야 하는 경우가 있음 — `requestExactAlarmsPermission()`이 설정 화면을 연다.
- iOS는 기본 설정만. 포그라운드 알림 표시 등 세부는 차후.
