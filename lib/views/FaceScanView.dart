import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io' show Platform;

class FaceScanView extends StatefulWidget {
  final Function(String) onFaceRecognized;

  const FaceScanView({super.key, required this.onFaceRecognized});

  @override
  State<FaceScanView> createState() => _FaceScanViewState();
}

class _FaceScanViewState extends State<FaceScanView> {
  CameraController? _cameraController;
  late List<CameraDescription> cameras;
  bool _isCameraInitialized = false;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    try {
      _faceDetector = GoogleMlKit.vision.faceDetector(
        FaceDetectorOptions(
          enableContours: true,
          enableClassification: true,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing FaceDetector: $e');
      _errorMessage = 'Lỗi khởi tạo FaceDetector: $e';
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      debugPrint('Available cameras: ${cameras.length}');
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Không tìm thấy camera trên thiết bị.';
        });
        return;
      }

      CameraDescription? frontCamera;
      for (var camera in cameras) {
        debugPrint('Camera: ${camera.name}, Lens Direction: ${camera.lensDirection}');
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy camera trước. Sử dụng camera mặc định.';
          _cameraController = CameraController(
            cameras[0],
            ResolutionPreset.medium,
          );
        });
      } else {
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
        );
      }

      await _cameraController!.initialize();
      debugPrint('Camera initialized successfully');
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        _errorMessage = 'Lỗi khởi tạo camera: $e';
      });
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting || _faceDetector == null) return;
    _isDetecting = true;

    final inputImage = await _convertCameraImage(image);
    if (inputImage == null) {
      debugPrint('Failed to convert CameraImage to InputImage');
      _isDetecting = false;
      return;
    }

    try {
      final faces = await _faceDetector!.processImage(inputImage);
      if (faces.isNotEmpty) {
        widget.onFaceRecognized('Face detected');
        _cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Error processing image with FaceDetector: $e');
    }

    _isDetecting = false;
  }

  Future<InputImage?> _convertCameraImage(CameraImage image) async {
    try {
      final allBytes = <int>[];
      for (var plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }
      final bytes = Uint8List.fromList(allBytes);

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final rotation = InputImageRotationValue.fromRawValue(
          _cameraController!.description.sensorOrientation) ??
          InputImageRotation.rotation0deg;
      final format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint("Error converting CameraImage to InputImage: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    try {
      _faceDetector?.close();
    } catch (e) {
      debugPrint('Error closing FaceDetector: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: CameraPreview(_cameraController!),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Vui lòng đặt gương mặt vào khung hình',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}