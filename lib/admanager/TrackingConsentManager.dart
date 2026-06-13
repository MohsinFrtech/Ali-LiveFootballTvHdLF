import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'google_consent.dart';

class TrackingConsentManager {
  final ConsentManager _consentManager = ConsentManager();

  /// Call this once from your first screen's initState or main.dart
  /// after the first frame is rendered.
  Future<void> requestPermissionsAndInitAds({
    required VoidCallback onReadyToLoadAds,
  }) async {
    if (Platform.isIOS) {
      await _requestATT();
    }
    await _gatherConsentWithRetry(
      onReadyToLoadAds: onReadyToLoadAds,
      attempt: 1,
    );
  }

  Future<void> _gatherConsentWithRetry({
    required VoidCallback onReadyToLoadAds,
    required int attempt,
    int maxAttempts = 5,
  }) async {
    // Exponential back-off: 400ms, 800ms, 1600ms, 3200ms
    final delay = Duration(milliseconds: 400 * attempt);
    await Future.delayed(delay);

    _consentManager.gatherConsent((error) async {
      if (error != null) {
        debugPrint('Consent error ${error.errorCode}: ${error.message}');

        // Error 9 = view controller conflict — wait and retry
        if (error.errorCode == 9 && attempt < maxAttempts) {
          debugPrint('Retrying consent (attempt $attempt of $maxAttempts)...');
          await _gatherConsentWithRetry(
            onReadyToLoadAds: onReadyToLoadAds,
            attempt: attempt + 1,
            maxAttempts: maxAttempts,
          );
          return;
        }

        // Other errors: proceed anyway, canRequestAds() will gate ad loading
      }

      final canShow = await _consentManager.canRequestAds();
      if (canShow) {
        onReadyToLoadAds();
      }
    });
  }

  Future<void> _requestATT() async {
    // ATT dialog must be shown AFTER the app UI is rendered.
    // A brief delay ensures the launch screen has fully dismissed.
    await Future.delayed(const Duration(milliseconds: 200));

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    // Only request if not yet determined — do NOT re-request on subsequent launches
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    debugPrint('ATT status: $status');
  }
}