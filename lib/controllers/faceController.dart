import 'dart:convert';
import 'package:camera/camera.dart';
import '../services/faceService.dart';

class FaceScanController {
  CameraController? cameraController;
  bool isDetecting = false;

  FaceScanController(CameraDescription camera) {
    cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
  }

  Future<void> initialize() async {
    await cameraController?.initialize();
  }

  Future<Map<String, dynamic>?> captureAndDetectFace() async {
    if (cameraController == null || !cameraController!.value.isInitialized || isDetecting) {
      return null;
    }

    try {
      isDetecting = true;
      final XFile image = await cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final result = await FaceApiService.detectFace(base64Image);
      return result;
    } catch (e) {
      print('Lỗi khi chụp hoặc nhận diện: $e');
      return null;
    } finally {
      isDetecting = false;
    }
  }

  void dispose() {
    cameraController?.dispose();
  }
}