import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../controllers/faceController.dart';
import '../services/infoStudentService.dart';

class FaceScanView extends StatefulWidget {
  const FaceScanView({super.key});

  @override
  State<FaceScanView> createState() => _FaceScanViewState();
}

class _FaceScanViewState extends State<FaceScanView> {
  FaceScanController? _controller;
  String _resultMessage = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Không tìm thấy camera trên thiết bị.';
        });
        return;
      }

      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      _controller = FaceScanController(frontCamera ?? cameras[0]);
      await _controller!.initialize();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khởi tạo camera: $e';
      });
    }
  }

  Future<void> _scanFace() async {
    if (_controller == null) return;

    setState(() {
      _resultMessage = 'Đang quét...';
    });

    final result = await _controller!.captureAndDetectFace();
    if (!mounted) return;

    setState(() {
      _resultMessage = '';
    });

    if (result == null) {
      _showAlertDialog('Lỗi', 'Không nhận diện được khuôn mặt');
      return;
    }

    // Giả sử result là Map<String, dynamic> chứa các trường 'match' và 'shouldSave'
    final match = result['match'];
    final shouldSave = result['shouldSave'] ?? false;
    final currentTime = DateTime.now().toString();

    switch (match) {
      case 'No face detected':
        _showAlertDialog('Lỗi', 'Không nhận diện được khuôn mặt');
        break;
      case 'unknown':
        _showAlertDialog('Thông báo', 'Không có dữ liệu khuôn mặt trong hệ thống');
        break;
      case 'Đã điểm danh':
        _showAlertDialog('Thông báo', 'Bạn đã điểm danh rồi');
        break;
      default:
      // Giả sử match là mã số sinh viên
        _handleAttendance(match, currentTime, shouldSave);
        break;
    }
  }

  Future<void> _handleAttendance(String mssv, String time, bool shouldSave) async {
    try {
      final studentName = await InfoStudentService.fetchStudentName(mssv);
      final status = shouldSave ? 'Thành công' : 'Không thành công';

      _showAlertDialog(
        'Điểm danh',
        'Điểm danh thành công\n'
            'Mã số sinh viên: $mssv\n'
            'Tên sinh viên: $studentName\n'
            'Thời gian: $time\n'
            'Trạng thái: $status',
      );
    } catch (e) {
      _showAlertDialog(
        'Lỗi',
        'Không thể lấy thông tin sinh viên: $e',
      );
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          if (_controller != null && _controller!.cameraController != null && _controller!.cameraController!.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.cameraController!.value.previewSize!.height,
                  height: _controller!.cameraController!.value.previewSize!.width,
                  child: CameraPreview(_controller!.cameraController!),
                ),
              ),
            ),

          // Hiển thị lỗi
          if (_errorMessage.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black54,
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Hiển thị loading
          if (_controller == null && _errorMessage.isEmpty)
            const Center(child: CircularProgressIndicator()),

          // Hướng dẫn và kết quả
          if (_controller != null && _controller!.cameraController != null && _errorMessage.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút quay lại
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Khung gợi ý
                Center(
                  child: Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(150),
                    ),
                  ),
                ),
                // Hướng dẫn, nút quét và kết quả
                Container(
                  padding: const EdgeInsets.all(20.0),
                  color: Colors.black54,
                  child: Column(
                    children: [
                      const Text(
                        'Vui lòng đặt gương mặt vào khung hình',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _scanFace,
                        child: const Text('Quét khuôn mặt'),
                      ),
                      if (_resultMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _resultMessage,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}