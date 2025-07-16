import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../edit_profile_viewmodel.dart';
import '../../../../config/language/app_localizations.dart';

class EditProfileLocationSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileLocationSection({super.key, required this.viewModel});

  @override
  State<EditProfileLocationSection> createState() =>
      _EditProfileLocationSectionState();
}

class _EditProfileLocationSectionState
    extends State<EditProfileLocationSection> {
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

  Future<void> _requestLocation() async {
    try {
      // 1. Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Requesting location...'),
            ],
          ),
        ),
      );

      // 2. Check for permissions and service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      // 3. Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Reverse geocode to get address details
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted && placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final city =
            place.subAdministrativeArea ??
            AppLocalizations.of(context).translate('unknown_city');
        final state =
            place.administrativeArea ??
            AppLocalizations.of(context).translate('unknown_state');
        final country =
            place.country ??
            AppLocalizations.of(context).translate('unknown_country');

        // 5. Update UI and ViewModel
        setState(() {
          _cityController.text = city;
          _stateController.text = state;
          _countryController.text = country;

          widget.viewModel.updateLocation(
            city: city,
            state: state,
            country: country,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully')),
        );
      } else {
        throw 'Could not get address from coordinates.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      }
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
            Text(
              'Your Location',
              style: ProfileTheme.getSubtitleStyle(context),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).translate('location_instruction'),
              style: ProfileTheme.getDescriptionStyle(context),
            ),
            const SizedBox(height: 16),

            // City Field with GPS button
            AppTextField(
              controller: _cityController,
              labelText: AppLocalizations.of(context).translate('city_label'),
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
                      builder:
                          (context, value, child) =>
                              Transform.scale(scale: value, child: child),
                      child: Icon(
                        Icons.gps_fixed,
                        color: ProfileTheme.darkPink,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              onSaved: (value) => widget.viewModel.updateLocation(city: value),
            ),

            const SizedBox(height: 12),

            // State Field
            AppTextField(
              controller: _stateController,
              labelText: AppLocalizations.of(context).translate('state_label'),
              labelStyle: ProfileTheme.getLabelStyle(context),
              prefixIcon: Icons.map,
              prefixIconColor: ProfileTheme.darkPink,
              readOnly: true,
              style: ProfileTheme.getInputTextStyle(context),
              onSaved: (value) => widget.viewModel.updateLocation(state: value),
            ),

            const SizedBox(height: 12),

            // Country Field
            AppTextField(
              controller: _countryController,
              labelText: AppLocalizations.of(
                context,
              ).translate('country_label'),
              labelStyle: ProfileTheme.getLabelStyle(context),
              prefixIcon: Icons.flag,
              prefixIconColor: ProfileTheme.darkPink,
              readOnly: true,
              style: ProfileTheme.getInputTextStyle(context),
              onSaved:
                  (value) => widget.viewModel.updateLocation(country: value),
            ),

            const SizedBox(height: 20),

            // Distance Preference
            Center(
              child: Text(
                'Preferred Distance (km)',
                style: ProfileTheme.getLabelStyle(context),
                textAlign: TextAlign.center,
              ),
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
                setState(
                  () => widget.viewModel.updateLocationPreference(val.round()),
                );
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
