import 'package:musiclibrary_relu/core/utills/app_strings.dart';

class GlobalException implements Exception {
  String message = AppStrings.noInternetConnection;
  GlobalException({required this.message});
  @override
  String toString() {
    return message;
  }
}
