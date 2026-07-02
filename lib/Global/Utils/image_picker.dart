import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PickedImage {
  File? _image;
  XFile? pickedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage({required Future<void> Function(File?) callBack}) async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressed = await _compress(pickedFile!.path);
      _image = compressed ?? File(pickedFile!.path);
      await callBack(_image);
    }
  }

  Future<void> pickMultiImages({
    required Future<void> Function(List<File>) callBack,
  }) async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    final files = <File>[];
    for (final xfile in picked) {
      final compressed = await _compress(xfile.path);
      files.add(compressed ?? File(xfile.path));
    }
    await callBack(files);
  }

  Future<File?> _compress(String path) async {
    try {
      final dir = await getTemporaryDirectory();
      final isPng = path.toLowerCase().endsWith('.png');
      final ext = isPng ? '.png' : '.jpg';
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_c$ext';
      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality: 75,
        minWidth: 1080,
        minHeight: 1080,
        format: isPng ? CompressFormat.png : CompressFormat.jpeg,
      );
      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }
}
