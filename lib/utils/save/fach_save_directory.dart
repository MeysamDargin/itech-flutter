import 'package:itech/models/save/category_save_list_model.dart';
import 'package:itech/service/saved/get_category_list.dart';

Future<CategoryListModel?> fetchAndParseCategoryList() async {
  try {
    final responseJson = await GetCategoryList.getCategoryList();

    if (responseJson['status'] == 'success') {
      final model = CategoryListModel.fromJson(responseJson);
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
