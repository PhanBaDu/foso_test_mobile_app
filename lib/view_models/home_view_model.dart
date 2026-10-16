import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/catalog.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(
    this.catalog, {
    DateTime Function()? now,
    bool startTimer = true,
  }) : _now = now ?? DateTime.now {
    _deadline = _now().add(Duration(seconds: catalog.flashSaleDurationSeconds));
    if (startTimer) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => refreshCountdown(),
      );
    }
  }
  final CatalogData catalog;
  final DateTime Function() _now;
  late final DateTime _deadline;
  Timer? _timer;
  int _banner = 1;
  int get banner => _banner;
  // Recompute from a deadline so backgrounding cannot make the counter drift.
  int get remainingSeconds =>
      ((_deadline.difference(_now()).inMilliseconds + 999) ~/ 1000).clamp(
        0,
        catalog.flashSaleDurationSeconds,
      );
  List<String> get clock {
    final seconds = remainingSeconds;
    return [
      seconds ~/ 3600,
      seconds % 3600 ~/ 60,
      seconds % 60,
    ].map((value) => value.toString().padLeft(2, '0')).toList(growable: false);
  }

  void selectBanner(int value) {
    if (value < 0 || value > 2 || value == _banner) return;
    _banner = value;
    notifyListeners();
  }

  void refreshCountdown() {
    notifyListeners();
    if (remainingSeconds == 0) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
