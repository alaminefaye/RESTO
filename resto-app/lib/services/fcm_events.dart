import 'dart:async';

class FCMEvents {
  // Stream pour notifier l'UI des mises à jour
  static final StreamController<bool> _orderUpdateController =
      StreamController<bool>.broadcast();
  static Stream<bool> get orderUpdateStream => _orderUpdateController.stream;

  static void triggerOrderUpdate() {
    _orderUpdateController.add(true);
  }
}
