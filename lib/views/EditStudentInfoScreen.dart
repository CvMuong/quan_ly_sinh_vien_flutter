import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_diem/models/infoStudentModel.dart';
import '../controllers/updateStudentInfoController.dart';

class EditStudentInfoScreen extends StatefulWidget {
  final InfoModel student;

  EditStudentInfoScreen({required this.student});

  @override
  _EditStudentInfoScreenState createState() => _EditStudentInfoScreenState();
}

class _EditStudentInfoScreenState extends State<EditStudentInfoScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  final InfoStudentController _controller = Get.find<InfoStudentController>();

  @override
  void initState() {
    super.initState();
    // Khởi tạo student trong controller từ widget.student
    _controller.student.value = widget.student;

    nameController = TextEditingController(text: _controller.student.value!.ho_ten);
    emailController = TextEditingController(text: _controller.student.value!.email);
    phoneController = TextEditingController(text: _controller.student.value!.sdt);
    addressController = TextEditingController(text: _controller.student.value!.dia_chi);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _saveInfo() async {
    await _controller.updateStudentInfo(
      idSinhVien: widget.student.id_sinh_vien,
      hoTen: nameController.text,
      email: emailController.text,
      sdt: phoneController.text,
      diaChi: addressController.text,
    );
    if (_controller.errorMessage.value.isEmpty) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage.value)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật thông tin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff6A82FB), Color(0xffFC5C7D)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildTextField(Icons.person, "Họ và tên", nameController),
            _buildTextField(Icons.email, "Email", emailController),
            _buildTextField(Icons.phone, "Số điện thoại", phoneController),
            _buildTextField(Icons.location_on, "Địa chỉ", addressController),
            SizedBox(height: 30),
            Obx(() => ElevatedButton(
              onPressed: _controller.isLoading.value ? null : _saveInfo,
              child: _controller.isLoading.value
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text("Lưu thông tin",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent, fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}