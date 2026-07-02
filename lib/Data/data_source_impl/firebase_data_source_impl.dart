import 'dart:io';
import '../../index/index_main.dart';
import '../models/core/error_handler_model.dart';

class FirebaseDataSourceImpl extends FirebaseDataSource {
  final FirebaseClient _firebaseClient;

  FirebaseDataSourceImpl(this._firebaseClient);

  @override
  Future<ApiResult<UserCredential>> loginWithFirebase(
    FirebaseAuthModel model,
  ) async {
    try {
      final credential = await _firebaseClient.signInUser(model);
      return Success(credential);
    } catch (error) {
      return Failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<UserCredential>> signupWithFirebase(
    FirebaseAuthModel model,
  ) async {
    try {
      final credential = await _firebaseClient.createUser(model);
      return Success(credential);
    } catch (error) {
      return Failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<String>> uploadImage(String key, File image) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(key);
      Loader.showUploadProgress();
      final task = ref.putFile(image);
      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          Loader.updateUploadProgress(
            snapshot.bytesTransferred / snapshot.totalBytes,
          );
        }
      });
      await task;
      Loader.hideUploadProgress();
      final url = await ref.getDownloadURL();
      return Success(url);
    } catch (error) {
      Loader.hideUploadProgress();
      return Failure(ErrorHandler.handle(error));
    }
  }
}
