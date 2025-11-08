import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class _MimePair {
  final String type;
  final String subtype;
  const _MimePair(this.type, this.subtype);
}

class CloudinaryService {
  CloudinaryService._();


  static const String cloudName = 'dlfto8vov';
  static const String unsignedUploadPreset = 'mentorloop_images';

  // Upload any file (image/video/pdf) to Cloudinary. Returns the secure_url.
  static Future<String> uploadFile({
    required File file,
    String resourceType = 'auto', // 'image' | 'video' | 'raw' | 'auto'
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/${resourceType == 'auto' ? 'auto' : resourceType}/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = unsignedUploadPreset;

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final mimeType = _inferMimeType(file.path);
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType(mimeType.type, mimeType.subtype),
    );

    request.files.add(multipartFile);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final secureUrl = _extractSecureUrl(response.body);
      if (secureUrl != null) return secureUrl;
      throw Exception('Upload succeeded but no secure_url in response');
    }

    throw Exception(
      'Cloudinary upload failed: ${response.statusCode} ${response.reasonPhrase}\n${response.body}',
    );
  }

  // Very small JSON parser to avoid heavy deps. Expects a key "secure_url":"..."
  static String? _extractSecureUrl(String body) {
    final match = RegExp(r'"secure_url"\s*:\s*"([^"]+)"').firstMatch(body);
    return match?.group(1);
  }

  static _MimePair _inferMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4')) return const _MimePair('video', 'mp4');
    if (lower.endsWith('.mov')) return const _MimePair('video', 'quicktime');
    if (lower.endsWith('.mkv')) return const _MimePair('video', 'x-matroska');
    if (lower.endsWith('.png')) return const _MimePair('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return const _MimePair('image', 'jpeg');
    }
    if (lower.endsWith('.pdf')) return const _MimePair('application', 'pdf');
    if (lower.endsWith('.doc')) return const _MimePair('application', 'msword');
    if (lower.endsWith('.docx')) {
      return const _MimePair(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    return const _MimePair('application', 'octet-stream');
  }
}
