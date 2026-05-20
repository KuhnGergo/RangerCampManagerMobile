enum InternetStatus { offline, mobile, wifi, ethernet }

extension InternetStatusExtension on InternetStatus {
  bool get isOnline => this != InternetStatus.offline;
}
