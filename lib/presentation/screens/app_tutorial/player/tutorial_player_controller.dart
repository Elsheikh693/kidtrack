import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../../../../index/index_main.dart';
import '../tutorial_progress_store.dart';

/// Streams a single tutorial video (progressive download from Firebase Storage,
/// so playback starts before the file is fully fetched). The video model is
/// passed via `Get.arguments`.
class TutorialPlayerController extends GetxController {
  late final TutorialVideoModel video;

  VideoPlayerController? _videoController;
  ChewieController? chewieController;

  final isReady = false.obs;
  final hasError = false.obs;
  final isCompleted = false.obs;
  final errorDetail = ''.obs;

  bool _marked = false;

  @override
  void onInit() {
    super.onInit();
    video = Get.arguments as TutorialVideoModel;
    load();
  }

  Future<void> load() async {
    hasError.value = false;
    errorDetail.value = '';
    isReady.value = false;

    final url = video.videoUrl.trim();
    if (url.isEmpty || Uri.tryParse(url)?.hasScheme != true) {
      AppLogger.error('TutorialPlayer', 'Invalid/empty video url: "$url"');
      errorDetail.value = 'رابط الفيديو غير صالح';
      hasError.value = true;
      return;
    }

    try {
      final vc = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController = vc;
      await vc.initialize();
      vc.addListener(_checkCompletion);
      chewieController = ChewieController(
        videoPlayerController: vc,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        aspectRatio:
            vc.value.aspectRatio == 0 ? 16 / 9 : vc.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: AppColors.grayLight,
          backgroundColor: AppColors.grayMedium,
        ),
      );
      isReady.value = true;
    } catch (e, s) {
      AppLogger.error('TutorialPlayer', 'Playback failed for $url', e, s);
      errorDetail.value = e.toString();
      hasError.value = true;
    }
  }

  /// Marks the step finished once playback reaches (near) the end. Persisted so
  /// the stepper reflects it after the user navigates back.
  void _checkCompletion() {
    if (_marked) return;
    final v = _videoController?.value;
    if (v == null || !v.isInitialized) return;
    final total = v.duration;
    if (total <= Duration.zero) return;
    if (v.position >= total - const Duration(milliseconds: 500)) {
      _marked = true;
      isCompleted.value = true;
      TutorialProgressStore.markWatched(video.key ?? '');
    }
  }

  @override
  void onClose() {
    _videoController?.removeListener(_checkCompletion);
    chewieController?.dispose();
    _videoController?.dispose();
    super.onClose();
  }
}
