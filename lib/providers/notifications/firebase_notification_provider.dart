import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';

final firebaseNotificationProvider =
    NotifierProvider<FirebaseNotificationProvider, void>(
      FirebaseNotificationProvider.new,
    );

class FirebaseNotificationProvider extends Notifier<void> {
  StreamSubscription<String>? _tokenRefreshSubscription;
  late final ApiHttpClient _httpClient;
  late final Endpoints _endpoints;
  late final FirebaseMessaging _firebaseMessaging;

  @override
  void build() {
    _httpClient = ref.read(httpClientProvider);
    _endpoints = ref.read(endpointsProvider);
    _firebaseMessaging = FirebaseMessaging.instance;

    ref.onDispose(() {
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = null;
    });
  }

  Future<void> setToken() async {
    _ensureTokenRefreshListener();

    final token = await _firebaseMessaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _sendToken(token);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to send FCM token to server',
        name: 'FirebaseNotificationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> stopTokenRefreshListener() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  void _ensureTokenRefreshListener() {
    if (_tokenRefreshSubscription != null) {
      return;
    }

    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(
      (token) async {
        if (token.isEmpty) {
          return;
        }

        try {
          await _sendToken(token);
        } catch (e, stackTrace) {
          developer.log(
            'Failed to update refreshed FCM token',
            name: 'FirebaseNotificationProvider',
            error: e,
            stackTrace: stackTrace,
          );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'FCM token refresh listener error',
          name: 'FirebaseNotificationProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> _sendToken(String token) async {
    final response = await _httpClient.post(
      _endpoints.myFcmTokens,
      body: {'token': token},
    );

    response.throwIfError();
  }
}
