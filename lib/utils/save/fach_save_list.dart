import 'package:itech/models/save/saved_items_response.dart';
import 'package:itech/service/saved/get_save_service.dart';

Future<SavedItemsResponse?> fetchSaveList() async {
  try {
    final responseJson = await GetSaveService.getSavelist();

    if (responseJson['status'] == 'success') {
      final model = SavedItemsResponse.fromJson(responseJson);
      return model;
    } else {
      // می‌تونی اینجا لاگ بزاری یا ارور نمایش بدی
      print('API returned error: ${responseJson['message']}');
      return null;
    }
  } catch (e) {
    print('Error in fetchAndParseCategoryList: $e');
    return null;
  }
}
