// filepath: c:\amoura-final-project\mobile-app\lib\presentation\settings\security\authentication\widgets\change_phone_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/data/repositories/user_repository.dart';
import '../../../../shared/widgets/app_gradient_background.dart';
import 'change_phone_viewmodel.dart';
import 'change_phone_form_widget.dart';

class ChangePhoneView extends StatelessWidget {
  const ChangePhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Change Phone Number'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ChangeNotifierProvider(
          create: (_) => ChangePhoneViewModel(userRepository: userRepository),
          child: const ChangePhoneFormWidget(),
        ),
      ),
    );
  }
}
