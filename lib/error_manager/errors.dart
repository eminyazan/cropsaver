import 'package:easy_localization/easy_localization.dart';
class ErrorManager {
  static String show(String errCode) {
    switch (errCode) {
      case 'invalid-email':
        return "invalid-email".tr();
      case 'emaıl-already-ın-use':
        return 'email-already-in-use'.tr();
      case 'wrong-password':
        return 'wrong-password'.tr();
      case 'user-not-found':
        return 'user-not-found'.tr();
      case 'operation-not-allowed':
        return 'operation-not-allowed'.tr();
      case 'weak-password':
        return 'weak-password'.tr();
      case 'user-not-verified':
        return 'user-not-verified'.tr();
      case 'network-request-failed':
        return 'network-request-failed'.tr();
      default:
        return 'unexpected_login_error'.tr();
    }
  }
}
