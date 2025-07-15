// Map of supported languages with their translations
final Map<String, Map<String, dynamic>> supportedLanguages = {
  'en': englishStrings,
  'vi': vietnameseStrings,
};

// English strings
final Map<String, dynamic> englishStrings = {
  // Common
  'app_name': 'Amoura',
  'ok': 'OK',
  'cancel': 'Cancel',
  'yes': 'Yes',
  'no': 'No',
  'save': 'Save',
  'back': 'Back',
  'next': 'Next',
  'continue': 'Continue',
  'done': 'Done',
  'skip': 'Skip',
  'send': 'Send',
  'update': 'Update',
  'create': 'Create',
  'confirm': 'Confirm',
  'close': 'Close',
  'apply': 'Apply',
  'retry': 'Retry',
  'verify': 'Verify',

  // Welcome Screen
  'welcome_title': 'Welcome to Amoura',
  'welcome_subtitle': 'Find your perfect match',
  'sign_in': 'Sign In',
  'register': 'Register',
  'sign_in_with': 'Sign in with',
  'create_new_account': 'CREATE NEW ACCOUNT',
  'welcome_slide1_title': 'Explore a World of Connections',
  'welcome_slide1_subtitle':
      'Find new friends, meaningful relationships, and more.',
  'welcome_slide2_title': 'Showcase Your Personality',
  'welcome_slide2_subtitle':
      'Create a unique profile, share your story and interests.',
  'welcome_slide3_title': 'Start Your Journey of Love',
  'welcome_slide3_subtitle':
      'Amoura - Where genuine connections are built and love flourishes.',
  'terms_agreement_text': 'By continuing, you agree to Amoura\'s ',
  'terms_service_link': 'Terms of Service',
  'and_text': ' and ',
  'privacy_policy_link': 'Privacy Policy',
  'email_phone_option': 'Email/Phone',
  'otp_verification_option': 'OTP Verification',

  // Login
  'login_title': 'Sign in to find your love',
  'email_phone': 'Email or Phone',
  'email_phone_hint': 'Enter email or phone',
  'password': 'Password',
  'password_hint': 'Enter your password',
  'forgot_password': 'Forgot password?',
  'dont_have_account': 'Don\'t have an account?',
  'register_now': 'Register now',
  'back_to_options': 'Back to options',
  'login_error': 'Email/Phone or password is incorrect',
  'language': 'Language',
  'select_language': 'Select Language',
  'or_sign_in_with': 'Or sign in with',
  'back_to_sign_in': 'Back to sign in',

  // Register
  'create_account': 'Create your Amoura account',
  'email': 'Email',
  'email_hint': 'Enter your email',
  'phone_number': 'Phone number',
  'phone_hint': 'Enter your phone number',
  'password_create': 'Password',
  'password_create_hint': 'Create a password',
  'confirm_password': 'Confirm password',
  'confirm_password_hint': 'Re-enter your password',
  'already_have_account': 'Already have an account?',
  'sign_in_now': 'Sign in now',
  'terms_agreement': 'I agree to the Terms of Service and Privacy Policy',
  'terms_service': 'Terms of Service',
  'privacy_policy': 'Privacy Policy',
  'terms_required':
      'You must agree to the Terms of Service to create an account',

  // Settings
  'settings': 'Settings',
  'account_profile': 'Account & Profile',
  'view_profile': 'View Profile',
  'edit_profile': 'Edit Profile',
  'account_security': 'Account & Security',
  'notification_settings': 'Notification Settings',
  'app_experience': 'App Experience',
  'theme': 'Theme',
  'system': 'System',
  'light': 'Light',
  'dark': 'Dark',
  'subscription_plans': 'Subscription Plans',
  'support_legal': 'Support & Legal',
  'legal_resources': 'Legal & Resources',
  'logout': 'Log Out',
  'app_version': 'App version',
  'logout_confirmation': 'Are you sure you want to log out of your account?',
  'yes_logout': 'Yes, Log Out',
  'no_cancel': 'No, Cancel',

  // Security
  'password_auth': 'Password & Authentication',
  'change_password': 'Change Password',
  'change_email': 'Change Email',
  'change_phone': 'Change Phone Number',
  'account_management': 'Account Management',
  'deactivate_account': 'Deactivate Account',
  'deactivate_subtitle': 'Temporarily disable your account',
  'delete_account': 'Delete Account Permanently',
  'delete_subtitle': 'This action cannot be undone',
  'delete_confirmation':
      'Are you absolutely sure you want to delete your account? This action cannot be undone and all your data will be lost.',
  'delete_permanently': 'Delete Permanently',

  // Change Email
  'verify_identity': 'Verify your identity',
  'password_continue':
      'Please enter your password to continue with email change.',
  'current_password': 'Your Password',
  'current_password_hint': 'Enter your current password',
  'current_password_required': 'Current password is required',
  'update_email': 'Update your email',
  'new_email_info':
      'Enter your new email address. We\'ll send a verification code to confirm the change.',
  'new_email': 'New Email Address',
  'new_email_hint': 'Enter new email address',
  'verify_email': 'Verify Email Change',
  'verification_sent':
      'We\'ve sent a verification code to your new email. Please enter the 6-digit code to confirm the change.',
  'otp_sent': 'OTP sent to your new email address. Please check and verify.',
  'invalid_otp': 'Invalid OTP. Please check and try again.',
  'email_change_success': 'Email changed successfully!',

  // Change Phone
  'update_phone_number': 'Update Phone Number',
  'phone_change_info':
      'To change your phone number, please enter your new number and verify with your password.',

  // Change Password
  'update_your_password': 'Update your password',
  'new_password': 'New Password',
  'confirm_new_password': 'Confirm New Password',
  'password_mismatch': 'Passwords do not match',
  'password_changed_success': 'Password changed successfully',

  // Error handling
  'error_occurred': 'An error occurred',

  // Subscription
  'amoura_vip': 'Amoura VIP',
  'subscription_selected': 'Subscription Selected',
  'payment_coming_soon': 'Payment functionality coming soon',
  'select_subscription_plan': 'Please select a subscription plan',
  'upgrade_to_vip': 'Upgrade to Amoura VIP',
  'maybe_later': 'Maybe Later',

  // Blocked Users
  'unblock': 'Unblock',
  'unblock_all': 'Unblock All',
  'no_blocked_users': 'No blocked users',
  'unblock_confirmation': 'Are you sure you want to unblock this user?',
  'unblock_all_confirmation': 'Are you sure you want to unblock all users?',
  'block_list': 'Block List',
  'unblock_message': 'Unblock Message',

  // Notifications
  'notification_settings_saved': 'Notification settings saved',
  'system_notifications': 'System Notifications',
  'system_notifications_desc':
      'Get notified about important app updates and announcements',
  'like_notifications': 'Like Notifications',
  'like_notifications_desc': 'Get notified when someone likes your profile',
  'message_notifications': 'Message Notifications',
  'message_notifications_desc': 'Get notified when you receive new messages',
  'all_notification_types': 'All Notification Types',
  'enable_disable_all': 'Enable or disable all notifications at once',
  'enable_all_notifications': 'Enable all notification types',

  // Chat Actions
  'reply': 'Reply',
  'edit': 'Edit',
  'delete': 'Delete',
  'copy': 'Copy',
  'pin': 'Pin',
  'unpin': 'Unpin',

  // Profile Setup
  'select_gender_error': 'Please select your gender',

  // Common titles
  'account_security_title': 'Account Security',
  'change_phone_title': 'Change Phone Number',
  'change_password_title': 'Change Password',
  'change_email_title': 'Change Email',
  'notification_settings_title': 'Notification Settings',
};

// Vietnamese strings
final Map<String, dynamic> vietnameseStrings = {
  // Common
  'app_name': 'Amoura',
  'ok': 'OK',
  'cancel': 'Hủy',
  'yes': 'Có',
  'no': 'Không',
  'save': 'Lưu',
  'back': 'Quay lại',
  'next': 'Tiếp theo',
  'continue': 'Tiếp tục',
  'done': 'Hoàn thành',
  'skip': 'Bỏ qua',
  'send': 'Gửi',
  'update': 'Cập nhật',
  'create': 'Tạo',
  'confirm': 'Xác nhận',
  'close': 'Đóng',
  'apply': 'Áp dụng',
  'retry': 'Thử lại',
  'verify': 'Xác minh',

  // Welcome Screen
  'welcome_title': 'Chào mừng đến với Amoura',
  'welcome_subtitle': 'Tìm người phù hợp với bạn',
  'sign_in': 'Đăng nhập',
  'register': 'Đăng ký',
  'sign_in_with': 'Đăng nhập với',
  'create_new_account': 'TẠO TÀI KHOẢN MỚI',
  'welcome_slide1_title': 'Khám phá thế giới kết nối',
  'welcome_slide1_subtitle':
      'Tìm bạn bè mới, mối quan hệ ý nghĩa và nhiều hơn nữa.',
  'welcome_slide2_title': 'Thể hiện cá tính của bạn',
  'welcome_slide2_subtitle':
      'Tạo hồ sơ độc đáo, chia sẻ câu chuyện và sở thích của bạn.',
  'welcome_slide3_title': 'Bắt đầu hành trình tình yêu',
  'welcome_slide3_subtitle':
      'Amoura - Nơi những kết nối chân thành được xây dựng và tình yêu nở hoa.',
  'terms_agreement_text': 'Bằng cách tiếp tục, bạn đồng ý với ',
  'terms_service_link': 'Điều khoản dịch vụ',
  'and_text': ' và ',
  'privacy_policy_link': 'Chính sách riêng tư',
  'email_phone_option': 'Email/Điện thoại',
  'otp_verification_option': 'Xác minh OTP',

  // Login
  'login_title': 'Đăng nhập để tìm tình yêu của bạn',
  'email_phone': 'Email hoặc Điện thoại',
  'email_phone_hint': 'Nhập email hoặc số điện thoại',
  'password': 'Mật khẩu',
  'password_hint': 'Nhập mật khẩu của bạn',
  'forgot_password': 'Quên mật khẩu?',
  'dont_have_account': 'Chưa có tài khoản?',
  'register_now': 'Đăng ký ngay',
  'back_to_options': 'Quay lại tùy chọn',
  'login_error': 'Email/Số điện thoại hoặc mật khẩu không chính xác',
  'language': 'Ngôn ngữ',
  'select_language': 'Chọn ngôn ngữ',
  'or_sign_in_with': 'Hoặc đăng nhập với',
  'back_to_sign_in': 'Quay lại đăng nhập',

  // Register
  'create_account': 'Tạo tài khoản Amoura của bạn',
  'email': 'Email',
  'email_hint': 'Nhập email của bạn',
  'phone_number': 'Số điện thoại',
  'phone_hint': 'Nhập số điện thoại của bạn',
  'password_create': 'Mật khẩu',
  'password_create_hint': 'Tạo mật khẩu',
  'confirm_password': 'Xác nhận mật khẩu',
  'confirm_password_hint': 'Nhập lại mật khẩu của bạn',
  'already_have_account': 'Đã có tài khoản?',
  'sign_in_now': 'Đăng nhập ngay',
  'terms_agreement': 'Tôi đồng ý với Điều khoản dịch vụ và Chính sách riêng tư',
  'terms_service': 'Điều khoản dịch vụ',
  'privacy_policy': 'Chính sách riêng tư',
  'terms_required': 'Bạn phải đồng ý với Điều khoản dịch vụ để tạo tài khoản',

  // Settings
  'settings': 'Cài đặt',
  'account_profile': 'Tài khoản & Hồ sơ',
  'view_profile': 'Xem hồ sơ',
  'edit_profile': 'Chỉnh sửa hồ sơ',
  'account_security': 'Tài khoản & Bảo mật',
  'notification_settings': 'Cài đặt thông báo',
  'app_experience': 'Trải nghiệm ứng dụng',
  'theme': 'Chủ đề',
  'system': 'Theo hệ thống',
  'light': 'Sáng',
  'dark': 'Tối',
  'subscription_plans': 'Gói đăng ký',
  'support_legal': 'Hỗ trợ & Pháp lý',
  'legal_resources': 'Pháp lý & Tài nguyên',
  'logout': 'Đăng xuất',
  'app_version': 'Phiên bản ứng dụng',
  'logout_confirmation':
      'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản của mình?',
  'yes_logout': 'Có, Đăng xuất',
  'no_cancel': 'Không, Hủy',

  // Security
  'password_auth': 'Mật khẩu & Xác thực',
  'change_password': 'Đổi mật khẩu',
  'change_email': 'Đổi email',
  'change_phone': 'Đổi số điện thoại',
  'account_management': 'Quản lý tài khoản',
  'deactivate_account': 'Tạm ngưng tài khoản',
  'deactivate_subtitle': 'Tạm thời vô hiệu hóa tài khoản của bạn',
  'delete_account': 'Xóa tài khoản vĩnh viễn',
  'delete_subtitle': 'Hành động này không thể hoàn tác',
  'delete_confirmation':
      'Bạn có chắc chắn muốn xóa tài khoản của mình? Hành động này không thể hoàn tác và tất cả dữ liệu của bạn sẽ bị mất.',
  'delete_permanently': 'Xóa vĩnh viễn',

  // Change Email
  'verify_identity': 'Xác minh danh tính của bạn',
  'password_continue':
      'Vui lòng nhập mật khẩu của bạn để tiếp tục với việc thay đổi email.',
  'current_password': 'Mật khẩu hiện tại',
  'current_password_hint': 'Nhập mật khẩu hiện tại của bạn',
  'current_password_required': 'Mật khẩu hiện tại là bắt buộc',
  'update_email': 'Cập nhật email của bạn',
  'new_email_info':
      'Nhập địa chỉ email mới. Chúng tôi sẽ gửi mã xác minh để xác nhận thay đổi.',
  'new_email': 'Địa chỉ email mới',
  'new_email_hint': 'Nhập địa chỉ email mới',
  'verify_email': 'Xác minh thay đổi email',
  'verification_sent':
      'Chúng tôi đã gửi mã xác minh đến email mới của bạn. Vui lòng nhập mã gồm 6 chữ số để xác nhận thay đổi.',
  'otp_sent':
      'OTP đã được gửi đến địa chỉ email mới của bạn. Vui lòng kiểm tra và xác minh.',
  'invalid_otp': 'OTP không hợp lệ. Vui lòng kiểm tra và thử lại.',
  'email_change_success': 'Đổi email thành công!',

  // Change Phone
  'update_phone_number': 'Cập nhật số điện thoại',
  'phone_change_info':
      'Để thay đổi số điện thoại, vui lòng nhập số mới và xác minh bằng mật khẩu.',

  // Change Password
  'update_your_password': 'Cập nhật mật khẩu của bạn',
  'new_password': 'Mật khẩu mới',
  'confirm_new_password': 'Xác nhận mật khẩu mới',
  'password_mismatch': 'Mật khẩu không khớp',
  'password_changed_success': 'Đổi mật khẩu thành công',

  // Error handling
  'error_occurred': 'Đã xảy ra lỗi',

  // Subscription
  'amoura_vip': 'Amoura VIP',
  'subscription_selected': 'Đã chọn gói đăng ký',
  'payment_coming_soon': 'Chức năng thanh toán sẽ sớm có',
  'select_subscription_plan': 'Vui lòng chọn gói đăng ký',
  'upgrade_to_vip': 'Nâng cấp lên Amoura VIP',
  'maybe_later': 'Để sau',

  // Blocked Users
  'unblock': 'Bỏ chặn',
  'unblock_all': 'Bỏ chặn tất cả',
  'no_blocked_users': 'Không có người dùng bị chặn',
  'unblock_confirmation': 'Bạn có chắc chắn muốn bỏ chặn người dùng này?',
  'unblock_all_confirmation':
      'Bạn có chắc chắn muốn bỏ chặn tất cả người dùng?',
  'block_list': 'Danh sách chặn',
  'unblock_message': 'Bỏ chặn tin nhắn',

  // Notifications
  'notification_settings_saved': 'Đã lưu cài đặt thông báo',
  'system_notifications': 'Thông báo hệ thống',
  'system_notifications_desc':
      'Nhận thông báo về các cập nhật ứng dụng quan trọng và thông báo',
  'like_notifications': 'Thông báo thích',
  'like_notifications_desc': 'Nhận thông báo khi ai đó thích hồ sơ của bạn',
  'message_notifications': 'Thông báo tin nhắn',
  'message_notifications_desc': 'Nhận thông báo khi bạn nhận được tin nhắn mới',
  'all_notification_types': 'Tất cả loại thông báo',
  'enable_disable_all': 'Bật hoặc tắt tất cả thông báo cùng một lúc',
  'enable_all_notifications': 'Bật tất cả loại thông báo',

  // Chat Actions
  'reply': 'Trả lời',
  'edit': 'Chỉnh sửa',
  'delete': 'Xóa',
  'copy': 'Sao chép',
  'pin': 'Ghim',
  'unpin': 'Bỏ ghim',

  // Profile Setup
  'select_gender_error': 'Vui lòng chọn giới tính của bạn',

  // Common titles
  'account_security_title': 'Bảo mật tài khoản',
  'change_phone_title': 'Đổi số điện thoại',
  'change_password_title': 'Đổi mật khẩu',
  'change_email_title': 'Đổi email',
  'notification_settings_title': 'Cài đặt thông báo',
};
