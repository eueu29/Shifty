import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';

class DevAlarmTestScreen extends StatefulWidget {
  const DevAlarmTestScreen({super.key});

  static const String routeName = '/dev/alarm-test';

  static bool get isAvailable => kDebugMode;

  @override
  State<DevAlarmTestScreen> createState() => _DevAlarmTestScreenState();
}

class _DevAlarmTestScreenState extends State<DevAlarmTestScreen> {
  static const int _testAlarmId = 9001;
  String _status = '대기 중';
  DateTime? _scheduledAt;
  Timer? _alarmTimer;

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  void _showAlarmDialog() {
    if (!mounted) return;
    setState(() {
      _status = '알람 울림!';
      _scheduledAt = null;
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.alarm, size: 48, color: Colors.red),
        title: const Text('알람!'),
        content: const Text('예약된 알람 시간이 되었습니다.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _schedule() async {
    await NotificationService.instance.initialize();
    final bool granted =
        await NotificationService.instance.requestPermissions();
    if (!granted) {
      if (!mounted) return;
      setState(() => _status = '권한 거부됨 — 설정에서 알림/정확한 알람을 허용해 주세요');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 또는 정확한 알람 권한이 필요합니다')),
      );
      return;
    }

    final DateTime when = DateTime.now().add(const Duration(minutes: 1));
    await NotificationService.instance.scheduleOneShot(
      id: _testAlarmId,
      when: when,
      title: '테스트 알람',
      body: '1분 뒤 예약된 알람입니다',
    );

    _alarmTimer?.cancel();
    _alarmTimer = Timer(const Duration(minutes: 1), _showAlarmDialog);

    if (!mounted) return;
    setState(() {
      _scheduledAt = when;
      _status = '예약 완료';
    });
  }

  Future<void> _cancel() async {
    await NotificationService.instance.cancel(_testAlarmId);
    _alarmTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _scheduledAt = null;
      _status = '취소됨';
    });
  }

  Future<void> _showPending() async {
    final pending = await NotificationService.instance.getPending();
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('예약된 알람 (${pending.length})'),
        content: SingleChildScrollView(
          child: Text(
            pending.isEmpty
                ? '없음'
                : pending
                    .map((p) => 'id=${p.id}\n title=${p.title}\n body=${p.body}')
                    .join('\n\n'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev: 알람 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('상태: $_status'),
            if (_scheduledAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('예정 시각: $_scheduledAt'),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _schedule,
              child: const Text('1분 뒤 알람 예약'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _cancel,
              child: const Text('예약 취소'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _showPending,
              child: const Text('예약 목록 확인'),
            ),
          ],
        ),
      ),
    );
  }
}
