import '../../../../core/databases/cache/cache_helper.dart';
import '../../../../core/errors/expentions.dart';
import '../models/template_model.dart';

abstract class TemplateLocalDataSource {
  Future<void> cacheTemplate(TemplateModel templateToCache);
  Future<TemplateModel> getLastTemplate();
}

class TemplateLocalDataSourceImpl implements TemplateLocalDataSource {
  final CacheHelper cacheHelper;
  TemplateLocalDataSourceImpl({required this.cacheHelper});

  @override
  Future<void> cacheTemplate(TemplateModel templateToCache) {
    return cacheHelper.saveData(
      key: "Template",
      value: templateToCache.toJson(),
    );
  }

  @override
  Future<TemplateModel> getLastTemplate() {
    final jsonString = cacheHelper.getData(key: "Template");
    if (jsonString != null) {
      return Future.value(TemplateModel.fromJson(jsonString));
    } else {
      throw CacheExeption(errorMessage: "No Template Cached");
    }
  }
}
