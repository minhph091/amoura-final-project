import 'package:flutter/material.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/constants/profile/sex_constants.dart';
import '../../../../core/constants/profile/orientation_constants.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../../theme/profile_theme.dart';
import '../edit_profile_viewmodel.dart';

class EditProfileBasicInfoSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileBasicInfoSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<EditProfileBasicInfoSection> createState() => _EditProfileBasicInfoSectionState();
}

class _EditProfileBasicInfoSectionState extends State<EditProfileBasicInfoSection> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();

  // Error flags
  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _dobError = false;
  bool _genderError = false;

  // Cache validation errors to avoid setState during build
  String? _firstNameErrorText;
  String? _lastNameErrorText;
  String? _dobErrorText;

  @override
  void initState() {
    super.initState();
    // Initialize controllers from viewModel
    _firstNameController.text = widget.viewModel.firstName ?? '';
    _lastNameController.text = widget.viewModel.lastName ?? '';
    if (widget.viewModel.dateOfBirth != null) {
      _dobController.text = DateUtil.formatDDMMYYYY(widget.viewModel.dateOfBirth!);
    }

    // Pre-validate to initialize error states
    _validateInitialFields();
  }

  void _validateInitialFields() {
    // Perform initial validation without setState
    _firstNameErrorText = widget.viewModel.validateFirstName(_firstNameController.text);
    _lastNameErrorText = widget.viewModel.validateLastName(_lastNameController.text);
    _dobErrorText = widget.viewModel.validateDob();

    // Set error flags based on validation results
    _firstNameError = _firstNameErrorText != null;
    _lastNameError = _lastNameErrorText != null;
    _dobError = _dobErrorText != null;
    _genderError = widget.viewModel.sex == null || widget.viewModel.sex!.isEmpty;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _handleFirstNameChanged(String value) {
    widget.viewModel.updateFirstName(value);

    // Validate and update error status after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _firstNameErrorText = widget.viewModel.validateFirstName(value);
          _firstNameError = _firstNameErrorText != null;
        });
      }
    });
  }

  void _handleLastNameChanged(String value) {
    widget.viewModel.updateLastName(value);

    // Validate and update error status after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _lastNameErrorText = widget.viewModel.validateLastName(value);
          _lastNameError = _lastNameErrorText != null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Information', style: ProfileTheme.getSubtitleStyle(context)),
        const SizedBox(height: 6),
        Text('Fields marked with * are required.',
            style: ProfileTheme.getDescriptionStyle(context)),
        const SizedBox(height: 16),

        // First Name (Step 1)
        ShakeWidget(
          shake: _firstNameError,
          child: AppTextField(
            controller: _firstNameController,
            labelText: "First Name *",
            labelStyle: ProfileTheme.getLabelStyle(context),
            prefixIcon: Icons.person,
            prefixIconColor: ProfileTheme.darkPink,
            maxLength: 50,
            // Use cached error text instead of calling validator directly
            errorText: _firstNameError ? _firstNameErrorText : null,
            onChanged: _handleFirstNameChanged,
            style: ProfileTheme.getInputTextStyle(context),
          ),
        ),

        const SizedBox(height: 12),

        // Last Name (Step 1)
        ShakeWidget(
          shake: _lastNameError,
          child: AppTextField(
            controller: _lastNameController,
            labelText: "Last Name *",
            labelStyle: ProfileTheme.getLabelStyle(context),
            prefixIcon: Icons.badge,
            prefixIconColor: ProfileTheme.darkPink,
            maxLength: 50,
            // Use cached error text
            errorText: _lastNameError ? _lastNameErrorText : null,
            onChanged: _handleLastNameChanged,
            style: ProfileTheme.getInputTextStyle(context),
          ),
        ),

        const SizedBox(height: 16),

        // Date of Birth (Step 2)
        ShakeWidget(
          shake: _dobError,
          child: GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: widget.viewModel.dateOfBirth ?? DateTime(now.year - 20),
                firstDate: DateTime(now.year - 120),
                lastDate: DateTime(now.year - 18),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: ProfileTheme.darkPink,
                        onPrimary: Colors.white,
                        onSurface: ProfileTheme.darkPurple,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && mounted) {
                widget.viewModel.updateDateOfBirth(picked);
                setState(() {
                  _dobController.text = DateUtil.formatDDMMYYYY(picked);
                  _dobErrorText = widget.viewModel.validateDob();
                  _dobError = _dobErrorText != null;
                });
              }
            },
            child: AbsorbPointer(
              child: AppTextField(
                labelText: 'Birthday *',
                labelStyle: ProfileTheme.getLabelStyle(context),
                prefixIcon: Icons.cake_rounded,
                prefixIconColor: ProfileTheme.darkPink,
                controller: _dobController,
                // Use cached error text
                errorText: _dobError ? _dobErrorText : null,
                style: ProfileTheme.getInputTextStyle(context),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Gender Label
        ShakeWidget(
          shake: _genderError,
          child: Text(
            'Gender *',
            style: ProfileTheme.getLabelStyle(context).copyWith(
              color: _genderError ? Colors.red : null,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Gender Options in 2-column grid
        _buildGenderGrid(),

        if (_genderError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Please select your gender',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 16),

        // Orientation Label
        Text('Orientation', style: ProfileTheme.getLabelStyle(context)),

        const SizedBox(height: 8),

        // Orientation Options in 2-column grid
        _buildOrientationGrid(),
      ],
    );
  }

  Widget _buildGenderGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: sexOptions.length,
      itemBuilder: (context, index) {
        final option = sexOptions[index];
        final isSelected = widget.viewModel.sex == option['value'];

        return _buildOptionItem(
          label: option['label'],
          icon: option['icon'],
          isSelected: isSelected,
          onTap: () {
            if (mounted) {
              setState(() {
                widget.viewModel.updateGender(option['value']);
                _genderError = false;
              });
            }
          },
        );
      },
    );
  }

  Widget _buildOrientationGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: orientationOptions.length,
      itemBuilder: (context, index) {
        final option = orientationOptions[index];
        final isSelected = widget.viewModel.orientation == option['value'];

        return _buildOptionItem(
          label: option['label'],
          icon: option['icon'],
          isSelected: isSelected,
          onTap: () {
            if (mounted) {
              setState(() {
                widget.viewModel.updateOrientation(option['value']);
              });
            }
          },
        );
      },
    );
  }

  Widget _buildOptionItem({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? ProfileTheme.darkPink : ProfileTheme.lightPurple,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? ProfileTheme.darkPink.withOpacity(0.1) : Colors.transparent,
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isSelected ? ProfileTheme.darkPink : ProfileTheme.lightPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? ProfileTheme.darkPink : ProfileTheme.darkPurple,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: ProfileTheme.darkPink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}