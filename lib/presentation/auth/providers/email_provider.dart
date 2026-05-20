import 'package:flutter_riverpod/flutter_riverpod.dart';

final emailProvider = NotifierProvider<EmailNotifier, String>(() {
  return EmailNotifier();
});

class EmailNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  set value(String value) {
    state = value;
  }

  void resetEmailExistence() {
    state = '';
  }
}
