import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:deteksipisang_app/config/app_config.dart';
import 'package:deteksipisang_app/models/prediction_result.dart';

class ApiService {
  static MediaType _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  static Future<PredictionResult> predict(File imageFile) async {
    final uri = Uri.parse(AppConfig.predictUrl);
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: _mimeType(imageFile.path),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return PredictionResult.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    throw Exception(body['detail'] ?? 'Prediksi gagal: ${response.statusCode}');
  }
}
