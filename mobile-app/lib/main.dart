import 'package:amoura/presentation/auth/setup_profile/setup_profile_view.dart';
import 'package:amoura/presentation/auth/setup_profile/setup_profile_viewmodel.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step10_bio_review_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step2_dob_gender_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step3_orientation_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step4_avatar_cover_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step5_location_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step6_appearance_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step7_job_education_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step8_lifestyle_form.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step9_interests_languages_form.dart';
import 'package:amoura/presentation/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/presentation/auth/setup_profile/steps/step1_name_form.dart';

void main() {
  runApp(
    MaterialApp(
      home: SetupProfileView(),
    ),
  );
}