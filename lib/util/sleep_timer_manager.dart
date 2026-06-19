import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 睡眠定时器管理器 - 所有播放器共用
class SleepTimerManager extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;

  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _remainingSeconds > 0;

  String get displayText {
    if (_remainingSeconds <= 0) return '';
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m}分${s}秒';
  }

  void start(int totalSeconds, {VoidCallback? onExpire}) {
    cancel();
    _totalSeconds = totalSeconds;
    _remainingSeconds = totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      notifyListeners();
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _timer = null;
        onExpire?.call();
      }
    });
    final minutes = totalSeconds ~/ 60;
    SmartDialog.showToast('睡眠定时：${minutes}分钟后停止播放');
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = 0;
    _totalSeconds = 0;
    notifyListeners();
    SmartDialog.showToast('已取消睡眠定时');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 显示睡眠定时器选择面板
  static void showSelector(BuildContext context, SleepTimerManager manager, {VoidCallback? onExpire}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('睡眠定时', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (manager.isActive)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('当前定时：${manager.displayText}后停止', style: const TextStyle(color: Colors.amber, fontSize: 14)),
              ),
            _option(ctx, manager, '15 分钟', 15 * 60, onExpire),
            _option(ctx, manager, '30 分钟', 30 * 60, onExpire),
            _option(ctx, manager, '1 小时', 60 * 60, onExpire),
            _option(ctx, manager, '2 小时', 120 * 60, onExpire),
            if (manager.isActive)
              _option(ctx, manager, '取消定时', 0, onExpire),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  static Widget _option(BuildContext ctx, SleepTimerManager manager, String label, int seconds, VoidCallback? onExpire) {
    return ListTile(
      leading: const Icon(Icons.timer_outlined, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(ctx);
        if (seconds == 0) {
          manager.cancel();
        } else {
          manager.start(seconds, onExpire: onExpire);
        }
      },
    );
  }
}
