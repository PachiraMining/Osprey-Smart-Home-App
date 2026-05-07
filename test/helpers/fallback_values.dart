import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/features/auth/data/models/login_request_model.dart';

/// Registers fallback values for non-primitive types used as `any()` matchers
/// in mocktail. Call once from `setUpAll` in any test that mocks methods
/// taking these types as arguments.
void registerCommonFallbacks() {
  registerFallbackValue(
    LoginRequestModel(email: '', password: ''),
  );
}
