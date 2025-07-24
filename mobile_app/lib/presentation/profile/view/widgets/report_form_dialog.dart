// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../setup/theme/setup_profile_theme.dart';
import 'dart:io';
import '../../../../config/language/app_localizations.dart';

class ReportFormDialog extends StatefulWidget {
  const ReportFormDialog({super.key});

  @override
  State<ReportFormDialog> createState() => _ReportFormDialogState();
}

class _ReportFormDialogState extends State<ReportFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  String? _selectedReason;

  // Giới hạn ký tự cho phần mô tả
  static const int _maxCharCount = 500;

  // Định nghĩa các lý do báo cáo
  final List<String> _reportReasons = [
    'Hồ sơ giả mạo',
    'Nội dung không phù hợp/Phản cảm',
    'Quấy rối/Bạo lực',
    'Spam/Quảng cáo',
    'Thông tin cá nhân giả mạo',
    'Hành vi xúc phạm',
    'Lừa đảo',
    'Khác',
  ];

  // Cấu hình cho việc tải ảnh
  static const int _maxImages = 4;
  static const double _maxFileSizeMB = 5.0;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImages() async {
    // Kiểm tra đã đạt số lượng ảnh tối đa chưa
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('report_max_images'),
          ),
        ),
      );
      return;
    }

    final pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages.isEmpty) return;

    for (var image in pickedImages) {
      // Kiểm tra kích thước file
      final file = File(image.path);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > _maxFileSizeMB) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ảnh ${image.name} vượt quá kích thước tối đa $_maxFileSizeMB MB',
            ),
          ),
        );
        continue;
      }

      if (_selectedImages.length < _maxImages) {
        setState(() {
          _selectedImages.add(file);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đạt giới hạn tối đa 4 hình ảnh')),
        );
        break;
      }
    }
  }

  // Hàm xóa ảnh đã chọn
  void _removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  // Kiểm tra form đã hợp lệ chưa
  bool get _isFormValid {
    return _selectedReason != null && _detailsController.text.isNotEmpty;
  }

  // Gửi báo cáo
  void _submitReport() {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      // Focus vào trường còn thiếu
      if (_selectedReason == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('select_report_reason'),
            ),
          ),
        );
      } else if (_detailsController.text.isEmpty) {
        FocusScope.of(context).requestFocus(FocusNode()..requestFocus());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('enter_report_details'),
            ),
          ),
        );
      }
      return;
    }

    // Xử lý gửi báo cáo
    // Trong thực tế, bạn sẽ gửi dữ liệu tới API

    // Hiển thị thông báo thành công
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).translate('report_sent_successfully'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ProfileTheme.darkPink.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      color: ProfileTheme.darkPink,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn cần báo cáo việc gì?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ProfileTheme.darkPurple,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vấn đề báo cáo:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Dropdown chọn lý do báo cáo
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReason,
                          isExpanded: true,
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('select_report_reason_title'),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items:
                              _reportReasons.map((reason) {
                                return DropdownMenuItem(
                                  value: reason,
                                  child: Text(reason),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedReason = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Mô tả chi tiết:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Textarea nhập chi tiết báo cáo
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _detailsController,
                        maxLines: 5,
                        maxLength: _maxCharCount,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).translate('enter_content_hint'),
                          contentPadding: const EdgeInsets.all(12),
                          border: InputBorder.none,
                          counterText: '', // Ẩn bộ đếm mặc định
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập chi tiết báo cáo';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Hiển thị số ký tự đã nhập
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_detailsController.text.length}/$_maxCharCount',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Hình ảnh minh họa (tùy chọn):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bạn có thể tải tối đa $_maxImages hình ảnh, mỗi ảnh không vượt quá $_maxFileSizeMB MB',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    // Phần tải hình ảnh
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Nút thêm ảnh
                          if (_selectedImages.length < _maxImages)
                            InkWell(
                              onTap: _pickImages,
                              child: Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                ),
                              ),
                            ),

                          // Hiển thị ảnh đã chọn
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(
                                            _selectedImages[index],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nút gửi báo cáo
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isFormValid
                                  ? ProfileTheme.darkPink
                                  : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _isFormValid ? _submitReport : null,
                        child: const Text(
                          'Gửi báo cáo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
