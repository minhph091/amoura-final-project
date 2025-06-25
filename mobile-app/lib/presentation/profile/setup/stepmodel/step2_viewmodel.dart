// lib/presentation/profile/setup/stepmodel/step2_viewmodel.dart
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/validation_util.dart';
import 'base_step_viewmodel.dart';

class Step2ViewModel extends BaseStepViewModel {
  DateTime? dateOfBirth;
  String? sex;

  Step2ViewModel(super.parent) {
    dateOfBirth = parent.dateOfBirth;
    sex = parent.sex;
  }

  @override
  bool get isRequired => true;

  @override
  String? validate() {
    if (sex == null || sex!.trim().isEmpty) return 'Please select your gender.';
    final dobError = ValidationUtil().validateBirthday(dateOfBirth);
    if (dobError != null) return dobError;
    return null;
  }

  @override
  void saveData() {
    parent.dateOfBirth = dateOfBirth;
    parent.sex = sex?.trim();
    parent.profileData['dateOfBirth'] = DateUtil.formatYYYYMMDD(dateOfBirth!);
    parent.profileData['sex'] = sex?.trim();
  }
}