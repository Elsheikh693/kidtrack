
import '../../index/index_main.dart';

class FirebaseClient {
  // Create User
  dynamic createUser(FirebaseAuthModel firebaseAuthModel) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: firebaseAuthModel.email,
            password: firebaseAuthModel.password,
          );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_weak_password'.tr,
        );
        throw errorModel;
      } else if (e.code == 'email-already-in-use') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_email_in_use'.tr,
        );
        throw errorModel;
      } else {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_create_account'.tr,
        );
        throw errorModel;
      }
    } catch (e) {
      ApiErrorModel errorModel = ApiErrorModel(message: e.toString());
      throw errorModel;
    }
  }

  // Sign In User
  dynamic signInUser(FirebaseAuthModel firebaseAuthModel) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: firebaseAuthModel.email,
        password: firebaseAuthModel.password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("cooode is ${e.code}");
      if (e.code == 'too-many-requests') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_server_busy'.tr,
        );
        throw errorModel;
      } else if (e.code == 'wrong-password') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_wrong_credentials'.tr,
        );
        throw errorModel;
      } else if (e.code == 'weak-password') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_weak_password'.tr,
        );
        throw errorModel;
      } else if (e.code == 'email-already-in-use') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_email_in_use'.tr,
        );
        throw errorModel;
      } else if (e.code == 'invalid-credential') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_invalid_credential'.tr,
        );
        throw errorModel;
      } else {
        ApiErrorModel errorModel = ApiErrorModel(
          message: 'datacore1_error_generic'.tr,
        );
        throw errorModel;
      }
    } catch (e) {
      ApiErrorModel errorModel = ApiErrorModel(message: e.toString());
      throw errorModel;
    }
  }
}
