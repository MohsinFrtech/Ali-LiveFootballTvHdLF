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
    bool shouldShowGDPR = true;

    if (Platform.isIOS) {
      // 1. Request ATT and see what the user chose
      final trackingStatus = await _requestATT();

      // 2. If the user denied tracking, Apple states you cannot show a tracking GDPR prompt
      // in the same flow. We will skip GDPR and try to load ads based on existing flags.
      if (trackingStatus == TrackingStatus.denied || trackingStatus == TrackingStatus.restricted) {
        shouldShowGDPR = false;

        // Check if we can still request non-personalized ads without showing the prompt
        final canShow = await _consentManager.canRequestAds();
        if (canShow) {
          onReadyToLoadAds();
        }
        return; // Exit early to respect "Ask App Not to Track"
      }
    }

    // 3. Only show GDPR if the user allowed tracking or if we are on Android
    if (shouldShowGDPR) {
      await _gatherConsentWithRetry(
        onReadyToLoadAds: onReadyToLoadAds,
        attempt: 1,
      );
    }
  }

  Future<void> _gatherConsentWithRetry({
    required VoidCallback onReadyToLoadAds,
    required int attempt,
    int maxAttempts = 5,
  }) async {
    final delay = Duration(milliseconds: 400 * attempt);
    await Future.delayed(delay);

    _consentManager.gatherConsent((error) async {
      if (error != null) {
        debugPrint('Consent error ${error.errorCode}: ${error.message}');

        if (error.errorCode == 9 && attempt < maxAttempts) {
          debugPrint('Retrying consent (attempt $attempt of $maxAttempts)...');
          await _gatherConsentWithRetry(
            onReadyToLoadAds: onReadyToLoadAds,
            attempt: attempt + 1,
            maxAttempts: maxAttempts,
          );
          return;
        }
      }

      final canShow = await _consentManager.canRequestAds();
      if (canShow) {
        onReadyToLoadAds();
      }
    });
  }

  // Changed return type to Future<TrackingStatus> to capture the user's choice
  Future<TrackingStatus> _requestATT() async {
    await Future.delayed(const Duration(milliseconds: 200));

    var status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      status = await AppTrackingTransparency.requestTrackingAuthorization();
    }

    debugPrint('ATT status: $status');
    return status;
  }
}



// import 'dart:io';
// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:flutter/material.dart';
// import 'google_consent.dart';
//
// class TrackingConsentManager {
//   final ConsentManager _consentManager = ConsentManager();
//
//   /// Call this once from your first screen's initState or main.dart
//   Future<void> requestPermissionsAndInitAds({
//     required VoidCallback onReadyToLoadAds,
//   }) async {
//     // 1. START with the GDPR/UMP Consent flow
//     await _gatherConsentWithRetry(
//       onReadyToLoadAds: onReadyToLoadAds,
//       attempt: 1,
//     );
//   }
//
//   Future<void> _gatherConsentWithRetry({
//     required VoidCallback onReadyToLoadAds,
//     required int attempt,
//     int maxAttempts = 5,
//   }) async {
//     final delay = Duration(milliseconds: 400 * attempt);
//     await Future.delayed(delay);
//
//     _consentManager.gatherConsent((error) async {
//       if (error != null) {
//         debugPrint('Consent error ${error.errorCode}: ${error.message}');
//         if (error.errorCode == 9 && attempt < maxAttempts) {
//           await _gatherConsentWithRetry(
//             onReadyToLoadAds: onReadyToLoadAds,
//             attempt: attempt + 1,
//             maxAttempts: maxAttempts,
//           );
//           return;
//         }
//       }
//
//       // 2. AFTER the GDPR prompt is dismissed (or skipped if not needed),
//       // request the iOS ATT permission.
//       if (Platform.isIOS) {
//         await _requestATT();
//       }
//
//       final canShow = await _consentManager.canRequestAds();
//       if (canShow) {
//         onReadyToLoadAds();
//       }
//     });
//   }
//
//   Future<void> _requestATT() async {
//     // Brief delay to ensure any previous UI (like UMP) is fully dismissed
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final status = await AppTrackingTransparency.trackingAuthorizationStatus;
//     if (status == TrackingStatus.notDetermined) {
//       await AppTrackingTransparency.requestTrackingAuthorization();
//     }
//     debugPrint('ATT status: $status');
//   }
// }






// import 'dart:io';
// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:flutter/material.dart';
// import 'google_consent.dart';
//
// class TrackingConsentManager {
//   final ConsentManager _consentManager = ConsentManager();
//
//   /// Call this once from your first screen's initState or main.dart
//   /// after the first frame is rendered.
//   Future<void> requestPermissionsAndInitAds({
//     required VoidCallback onReadyToLoadAds,
//   }) async {
//     if (Platform.isIOS) {
//       await _requestATT();
//     }
//     await _gatherConsentWithRetry(
//       onReadyToLoadAds: onReadyToLoadAds,
//       attempt: 1,
//     );
//   }
//
//   Future<void> _gatherConsentWithRetry({
//     required VoidCallback onReadyToLoadAds,
//     required int attempt,
//     int maxAttempts = 5,
//   }) async {
//     // Exponential back-off: 400ms, 800ms, 1600ms, 3200ms
//     final delay = Duration(milliseconds: 400 * attempt);
//     await Future.delayed(delay);
//
//     _consentManager.gatherConsent((error) async {
//       if (error != null) {
//         debugPrint('Consent error ${error.errorCode}: ${error.message}');
//
//         // Error 9 = view controller conflict — wait and retry
//         if (error.errorCode == 9 && attempt < maxAttempts) {
//           debugPrint('Retrying consent (attempt $attempt of $maxAttempts)...');
//           await _gatherConsentWithRetry(
//             onReadyToLoadAds: onReadyToLoadAds,
//             attempt: attempt + 1,
//             maxAttempts: maxAttempts,
//           );
//           return;
//         }
//
//         // Other errors: proceed anyway, canRequestAds() will gate ad loading
//       }
//
//       final canShow = await _consentManager.canRequestAds();
//       if (canShow) {
//         onReadyToLoadAds();
//       }
//     });
//   }
//
//   Future<void> _requestATT() async {
//     // ATT dialog must be shown AFTER the app UI is rendered.
//     // A brief delay ensures the launch screen has fully dismissed.
//     await Future.delayed(const Duration(milliseconds: 200));
//
//     final status = await AppTrackingTransparency.trackingAuthorizationStatus;
//
//     // Only request if not yet determined — do NOT re-request on subsequent launches
//     if (status == TrackingStatus.notDetermined) {
//       await AppTrackingTransparency.requestTrackingAuthorization();
//     }
//
//     debugPrint('ATT status: $status');
//   }
// }