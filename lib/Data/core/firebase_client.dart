
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
          message: "كلمة المرور ضعيفة جدًا.",
        );
        throw errorModel;
      } else if (e.code == 'email-already-in-use') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: "هذا البريد الإلكتروني مستخدم بالفعل.",
        );
        throw errorModel;
      } else {
        ApiErrorModel errorModel = ApiErrorModel(
          message: "حدث خطأ أثناء إنشاء الحساب. الرجاء المحاولة مرة أخرى.",
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
          message: "الخادم مشغول، يرجى المحاولة لاحقًا.",
        );
        throw errorModel;
      } else if (e.code == 'wrong-password') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: "البريد الإلكتروني أو كلمة المرور غير صحيحة.",
        );
        throw errorModel;
      } else if (e.code == 'weak-password') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: "كلمة المرور ضعيفة جدًا.",
        );
        throw errorModel;
      } else if (e.code == 'email-already-in-use') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: "هذا البريد الإلكتروني مستخدم بالفعل.",
        );
        throw errorModel;
      } else if (e.code == 'invalid-credential') {
        ApiErrorModel errorModel = ApiErrorModel(
          message: "بيانات الدخول غير صالحة. يرجى التحقق.",
        );
        throw errorModel;
      } else {
        ApiErrorModel errorModel = ApiErrorModel(
          message: "حدث خطأ ما، يرجى المحاولة مرة أخرى.",
        );
        throw errorModel;
      }
    } catch (e) {
      ApiErrorModel errorModel = ApiErrorModel(message: e.toString());
      throw errorModel;
    }
  }
}
