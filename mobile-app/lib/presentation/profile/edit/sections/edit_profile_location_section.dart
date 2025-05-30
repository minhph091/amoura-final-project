import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../../theme/profile_theme.dart';
import '../edit_profile_viewmodel.dart';

class EditProfileLocationSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileLocationSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<EditProfileLocationSection> createState() => _EditProfileLocationSectionState();
}

class _EditProfileLocationSectionState extends State<EditProfileLocationSection> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.viewModel.city ?? '';
    _stateController.text = widget.viewModel.state ?? '';
    _countryController.text = widget.viewModel.country ?? '';
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _requestLocation() async {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Requesting location...')
        ],
      )),
    );

    // This would typically be a real location request
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Here we would update with real location data
      // For the demo, we'll use placeholder values
      setState(() {
        _cityController.text = 'New York';
        _stateController.text = 'NY';
        _countryController.text = 'United States';

        widget.viewModel.updateLocation(
          city: 'New York',
          state: 'NY',
          country: 'United States',
        );
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Location', style: ProfileTheme.getSubtitleStyle(context)),
            const SizedBox(height: 6),
            Text('Tap the GPS icon to automatically detect your location.',
                style: ProfileTheme.getDescriptionStyle(context)),
            const SizedBox(height: 16),

            // City Field with GPS button
            AppTextField(
              controller: _cityController,
              labelText: 'City',
              labelStyle: ProfileTheme.getLabelStyle(context),
              prefixIcon: Icons.location_city,
              prefixIconColor: ProfileTheme.darkPink,
              readOnly: true,
              style: ProfileTheme.getInputTextStyle(context),
              suffixIcon: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _requestLocation,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ProfileTheme.darkPink.withAlpha(38),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 1.2),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) => Transform.scale(scale: value, child: child),
                      child: Icon(Icons.gps_fixed, color: ProfileTheme.darkPink, size: 24),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // State Field
            AppTextField(
              controller: _stateController,
              labelText: 'State',
              labelStyle: ProfileTheme.getLabelStyle(context),
              prefixIcon: Icons.map,
              prefixIconColor: ProfileTheme.darkPink,
              readOnly: true,
              style: ProfileTheme.getInputTextStyle(context),
            ),

            const SizedBox(height: 12),

            // Country Field
            AppTextField(
              controller: _countryController,
              labelText: 'Country',
              labelStyle: ProfileTheme.getLabelStyle(context),
              prefixIcon: Icons.flag,
              prefixIconColor: ProfileTheme.darkPink,
              readOnly: true,
              style: ProfileTheme.getInputTextStyle(context),
            ),

            const SizedBox(height: 20),

            // Distance Preference
            Center(
              child: Text('Preferred Distance (km)',
                  style: ProfileTheme.getLabelStyle(context),
                  textAlign: TextAlign.center),
            ),

            // Distance Slider
            Slider(
              value: (widget.viewModel.locationPreference ?? 10).toDouble(),
              min: 1,
              max: 300,
              divisions: 30,
              label: "${widget.viewModel.locationPreference ?? 10} km",
              activeColor: ProfileTheme.darkPink,
              inactiveColor: ProfileTheme.darkPurple.withAlpha(77),
              onChanged: (val) {
                setState(() => widget.viewModel.updateLocationPreference(val.round()));
              },
            ),

            Center(
              child: Text(
                '${widget.viewModel.locationPreference ?? 10} km',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ProfileTheme.darkPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}