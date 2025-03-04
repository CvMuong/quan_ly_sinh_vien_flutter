import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScanView extends StatefulWidget {
  final Function(String) onQRCodeScanned;

  const QRScanView({required this.onQRCodeScanned, super.key});

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanned && scanData.code != null) {
        setState(() {
          isScanned = true; // Ngăn quét lại nhiều lần
        });
        widget.onQRCodeScanned(scanData.code!);
        _showResultDialog(scanData.code!); // Hiển thị thông báo
      }
    });
  }

  // Kiểm tra xem chuỗi có phải là URL không
  bool _isUrl(String code) {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\w\d\-_]+\.)+[\w\d\-_]+(\/.*)?$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(code);
  }

  // Mở URL trong trình duyệt
  Future<void> _launchUrl(String url) async {
    // debugPrint('URL gốc: $url');
    String finalUrl = url.startsWith('http') ? url : 'https://$url';
    Uri uri = Uri.parse(finalUrl);
    // debugPrint('Đang mở URL: $uri');

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Mở trong trình duyệt ngoài
      );
      debugPrint('Đã mở trình duyệt thành công');
    } catch (e) {
      debugPrint('Lỗi khi mở trình duyệt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Mã QR đã quét', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Dữ liệu: $code', style: const TextStyle(fontSize: 16)),
          actions: [
            if (_isUrl(code))
              TextButton(
                onPressed: () async {
                  await _launchUrl(code); // Mở trình duyệt ngay lập tức
                },
                child: const Text('Mở link', style: TextStyle(color: Colors.blue)),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Đóng', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.red,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: 250,
          ),
        ),
        Positioned(
          bottom: 20,
          child: Text(
            'Đặt mã QR vào giữa khung',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              backgroundColor: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}