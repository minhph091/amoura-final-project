// lib/presentation/discovery/widgets/filter_dialog.dart
// Modal dialog for filters (age, distance, etc.)

// lib/presentation/discovery/widgets/filter_dialog.dart

import 'package:flutter/material.dart';
import '../../common/common_info_view.dart'; // Để dùng AppTextStyles nếu muốn hoặc Theme.of(context).textTheme
import '../../../config/theme/app_colors.dart'; // Để dùng các màu của theme
import '../../../config/theme/text_styles.dart'; // Để dùng AppTextStyles
import '../../../core/constants/profile/interest_constants.dart'; // Để lấy interestOptions
import '../../shared/widgets/profile_option_selector.dart'; // Tái sử dụng ProfileOptionSelector

// Để có thể sử dụng showFilterDialog từ bên ngoài
Future<void> showFilterDialog(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Cho phép bottom sheet chiếm gần hết màn hình
    backgroundColor: Colors.transparent, // Để lộ borderRadius của container bên trong
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Bo góc trên
    ),
    builder: (ctx) => const FilterDialogContent(),
  );
}

class FilterDialogContent extends StatefulWidget {
  const FilterDialogContent({super.key});

  @override
  State<FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<FilterDialogContent> {
  // Giá trị mặc định cho bộ lọc tuổi
  RangeValues _ageRange = const RangeValues(18, 60);
  // Giá trị mặc định cho bộ lọc khoảng cách (km)
  RangeValues _distanceRange = const RangeValues(0, 100);
  // Danh sách các sở thích được chọn
  List<String> _selectedInterestIds = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị mặc định hoặc từ trạng thái đã lưu (nếu có)
    _ageRange = const RangeValues(18, 60); // Ví dụ: từ 18 đến 60 tuổi
    _distanceRange = const RangeValues(0, 100); // Ví dụ: từ 0 đến 100 km
    _selectedInterestIds = []; // Bắt đầu với không có sở thích nào được chọn
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 60);
      _distanceRange = const RangeValues(0, 100);
      _selectedInterestIds = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters have been reset.')),
    );
  }

  void _applyFilters() {
    // Logic áp dụng bộ lọc.
    // Trong môi trường thực, bạn sẽ gửi các giá trị này đến ViewModel/Bloc/Cubit
    // hoặc một callback để xử lý.
    // Ví dụ:
    print('Applying filters:');
    print('Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}');
    print('Distance Range: ${_distanceRange.start.round()} - ${_distanceRange.end.round()} km');
    print('Selected Interests: $_selectedInterestIds');

    Navigator.of(context).pop(); // Đóng dialog sau khi áp dụng
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.8, // Bắt đầu chiếm 80% màn hình
      minChildSize: 0.5,     // Kéo xuống tối thiểu 50%
      maxChildSize: 0.9,     // Kéo lên tối đa 90%
      expand: false,         // Không mở rộng hết màn hình ngay lập tức
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface, // Sử dụng màu nền từ theme
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Thanh kéo để đóng dialog
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController, // Gắn scrollController vào SingleChildScrollView
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discovery Filters',
                        style: AppTextStyles.heading1.copyWith(color: colorScheme.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Filter: Age Range
                      Text(
                        'Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
                        style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
                      ),
                      RangeSlider(
                        values: _ageRange,
                        min: 18,
                        max: 99,
                        divisions: 81, // 99 - 18 = 81
                        labels: RangeLabels(
                          _ageRange.start.round().toString(),
                          _ageRange.end.round().toString(),
                        ),
                        onChanged: (values) {
                          setState(() {
                            _ageRange = values;
                          });
                        },
                        activeColor: colorScheme.primary,
                        inactiveColor: colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 24),

                      // Filter: Distance Range
                      Text(
                        'Distance: ${_distanceRange.start.round()} - ${_distanceRange.end.round()} km',
                        style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
                      ),
                      RangeSlider(
                        values: _distanceRange,
                        min: 0,
                        max: 500, // Ví dụ: tối đa 500km
                        divisions: 500, // 500 - 0 = 500
                        labels: RangeLabels(
                          _distanceRange.start.round().toString() + ' km',
                          _distanceRange.end.round().toString() + ' km',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _distanceRange = values;
                          });
                        },
                        activeColor: colorScheme.primary,
                        inactiveColor: colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 24),

                      // Filter: Interests
                      Text(
                        'Interests',
                        style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 12),
                      ProfileOptionSelector(
                        options: interestOptions, // Sử dụng dữ liệu interestOptions đã có
                        selectedValues: _selectedInterestIds,
                        onChanged: (value, selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterestIds.add(value);
                            } else {
                              _selectedInterestIds.remove(value);
                            }
                          });
                        },
                        labelText: 'Select your interests',
                        labelStyle: AppTextStyles.body.copyWith(color: colorScheme.label),
                        isMultiSelect: true,
                        scrollable: false, // Để ProfileOptionSelector tự quản lý scroll
                        isSearchable: true,
                      ),
                      const SizedBox(height: 30),

                      // Buttons: Reset and Apply
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetFilters,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.secondary, width: 2),
                                foregroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                              ),
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                                elevation: 0,
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}