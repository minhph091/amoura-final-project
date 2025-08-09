import 'package:flutter/material.dart';
import '../shared/widgets/app_gradient_background.dart';
import '../../config/language/app_localizations.dart';

class VipSubscriptionView extends StatelessWidget {
  const VipSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            localizations.translate('amoura_vip'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.diamond,
                size: 80,
                color: Colors.white54,
              ),
              SizedBox(height: 24),
              Text(
                'VIP Features',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
