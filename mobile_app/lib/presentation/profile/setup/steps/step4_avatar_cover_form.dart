import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/language/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/auth_service.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step4_viewmodel.dart';
import 'package:get_it/get_it.dart';

class Step4AvatarCoverForm extends StatefulWidget {
  const Step4AvatarCoverForm({super.key});

  @override
  State<Step4AvatarCoverForm> createState() => _Step4AvatarCoverFormState();
}

class _Step4AvatarCoverFormState extends State<Step4AvatarCoverForm> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    // Lấy access token khi khởi tạo
    _loadAccessToken();
  }

  Future<void> _loadAccessToken() async {
    final authService = GetIt.I<AuthService>();
    _accessToken = await authService.getAccessToken();
    if (mounted) setState(() {});
  }

  // Điều chỉnh URL cho emulator
  String _adjustUrl(String url) {
    if (kIsWeb) return url; // Không thay đổi trên web
    if (Platform.isAndroid && !kIsWeb) {
      // Thay localhost và 127.0.0.1 bằng 10.0.2.2 cho emulator Android
      return url
          .replaceFirst('localhost', '10.0.2.2')
          .replaceFirst('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  void _showImageOptions(BuildContext context, bool isAvatar, String path) {
    final step4ViewModel = Provider.of<Step4ViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).translate('photo_options'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  step4ViewModel.editImage(context, path, isAvatar);
                },
                child: Text(
                  AppLocalizations.of(context).translate('edit_photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  step4ViewModel.pickImage(context, isAvatar);
                },
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('choose_another_photo'),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final step4ViewModel = vm.stepViewModels[3] as Step4ViewModel;

    // Wrap widget với ChangeNotifierProvider để lắng nghe Step4ViewModel
    return ChangeNotifierProvider<Step4ViewModel>.value(
      value: step4ViewModel,
      child: Consumer<Step4ViewModel>(
        builder: (context, step4ViewModel, child) {
          // Log URL để debug
          if (step4ViewModel.avatarPath != null) {
            final adjustedAvatarUrl = _adjustUrl(step4ViewModel.avatarPath!);
            debugPrint('Adjusted Avatar image url: $adjustedAvatarUrl');
          }
          if (step4ViewModel.coverPath != null) {
            final adjustedCoverUrl = _adjustUrl(step4ViewModel.coverPath!);
            debugPrint('Adjusted Cover image url: $adjustedCoverUrl');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    final localizations = AppLocalizations.of(context);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('step4_title'),
                          style: ProfileTheme.getTitleStyle(context),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          localizations.translate('step4_description'),
                          style: ProfileTheme.getDescriptionStyle(context),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: GestureDetector(
                              onTap: () {
                                if (step4ViewModel.avatarPath == null) {
                                  step4ViewModel.pickImage(context, true);
                                } else {
                                  _showImageOptions(
                                    context,
                                    true,
                                    step4ViewModel.avatarPath!,
                                  );
                                }
                              },
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ProfileTheme.darkPink.withAlpha(
                                        20,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ProfileTheme.darkPink,
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        step4ViewModel.avatarPath == null
                                            ? const Center(
                                              child: Icon(
                                                Icons.camera_alt,
                                                size: 48,
                                                color: ProfileTheme.darkPink,
                                              ),
                                            )
                                            : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: _adjustUrl(
                                                  step4ViewModel.avatarPath!,
                                                ),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                memCacheWidth:
                                                    512, // Giảm tải bộ nhớ
                                                httpHeaders:
                                                    _accessToken != null
                                                        ? {
                                                          'Authorization':
                                                              'Bearer $_accessToken',
                                                        }
                                                        : null,
                                                errorWidget: (
                                                  context,
                                                  url,
                                                  error,
                                                ) {
                                                  debugPrint(
                                                    'Error loading avatar: $error, URL: ${_adjustUrl(step4ViewModel.avatarPath!)}',
                                                  );
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.error,
                                                      size: 48,
                                                      color: Colors.red,
                                                    ),
                                                  );
                                                },
                                                placeholder: (context, url) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              ),
                                            ),
                                  ),
                                  if (step4ViewModel.avatarPath != null)
                                    GestureDetector(
                                      onTap: () async {
                                        await step4ViewModel.deleteImage(
                                          context,
                                          true,
                                        ); // Xóa ảnh trên backend
                                        setState(() {
                                          step4ViewModel.avatarPath = null;
                                          vm.avatarPath = null;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 2,
                                              color: Color(0xFF424242),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: ProfileTheme.darkPink,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Avatar",
                            style: ProfileTheme.getLabelStyle(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Your main profile photo",
                            style: ProfileTheme.getDescriptionStyle(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: GestureDetector(
                              onTap: () {
                                if (step4ViewModel.coverPath == null) {
                                  step4ViewModel.pickImage(context, false);
                                } else {
                                  _showImageOptions(
                                    context,
                                    false,
                                    step4ViewModel.coverPath!,
                                  );
                                }
                              },
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ProfileTheme.darkPurple.withAlpha(
                                        25,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ProfileTheme.darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        step4ViewModel.coverPath == null
                                            ? const Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 48,
                                                color: ProfileTheme.darkPurple,
                                              ),
                                            )
                                            : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: _adjustUrl(
                                                  step4ViewModel.coverPath!,
                                                ),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                memCacheWidth:
                                                    1024, // Giảm tải bộ nhớ
                                                httpHeaders:
                                                    _accessToken != null
                                                        ? {
                                                          'Authorization':
                                                              'Bearer $_accessToken',
                                                        }
                                                        : null,
                                                errorWidget: (
                                                  context,
                                                  url,
                                                  error,
                                                ) {
                                                  debugPrint(
                                                    'Error loading cover: $error, URL: ${_adjustUrl(step4ViewModel.coverPath!)}',
                                                  );
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.error,
                                                      size: 48,
                                                      color: Colors.red,
                                                    ),
                                                  );
                                                },
                                                placeholder: (context, url) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              ),
                                            ),
                                  ),
                                  if (step4ViewModel.coverPath != null)
                                    GestureDetector(
                                      onTap: () async {
                                        await step4ViewModel.deleteImage(
                                          context,
                                          false,
                                        ); // Xóa ảnh trên backend
                                        setState(() {
                                          step4ViewModel.coverPath = null;
                                          vm.coverPath = null;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 2,
                                              color: Color(0xFF424242),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: ProfileTheme.darkPurple,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Cover Photo",
                            style: ProfileTheme.getLabelStyle(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Large background photo",
                            style: ProfileTheme.getDescriptionStyle(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SetupProfileButton(
                  text: AppLocalizations.of(
                    context,
                  ).translate('continue_setup'),
                  onPressed: () {
                    final error = step4ViewModel.validate();
                    if (error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                      return;
                    }
                    vm.nextStep(context: context);
                  },
                  width: double.infinity,
                  height: 52,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
