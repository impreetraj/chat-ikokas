import 'package:local_auth/local_auth.dart';

class BioMatric {
  final LocalAuthentication localauth = LocalAuthentication();

  Future<bool> authenticateLocally() async {
    bool isAuthenticate = false;

    try {
      isAuthenticate = await localauth.authenticate(
        localizedReason: "Please authenticate to access the app",
      );
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        // Add handling of no hardware here.
      } else if (e.code == LocalAuthExceptionCode.temporaryLockout ||
          e.code == LocalAuthExceptionCode.biometricLockout) {
        // ...
      } else {
        // ...
      }
    } catch (e) {
      isAuthenticate = false;
    }

    return isAuthenticate;
  }
}

