import 'package:dio/dio.dart';
import '../models/template_model.dart';
import '../../domain/repositories/template_repository.dart';

class TemplateRemoteDataSource {
  final Dio dio;

  TemplateRemoteDataSource({required this.dio});

  Future<TemplateModel> getTemplate(TemplateParams params) async {
    final response = await dio.get("/templates/${params.templateId}");
    return TemplateModel.fromJson(response.data);
  }
}
