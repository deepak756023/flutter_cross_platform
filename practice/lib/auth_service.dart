import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class AuthService {
  final LocalAuthentication localAuth = LocalAuthentication();

  Future<bool> authenticateLocally() async {
    bool isAutenticate = false;

    try {
      isAutenticate = await localAuth.authenticate(
        localizedReason: "Touch the fingerprint sensor",
        options: AuthenticationOptions(
          useErrorDialogs: false,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.notEnrolled) {
        // ...
      } else {
        // ...
      }
    } catch (e) {
      isAutenticate = false;
      print("Error: $e");
    }
    return isAutenticate;
  }
}
