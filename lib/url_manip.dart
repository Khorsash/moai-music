import 'package:http/http.dart' as http;

enum UrlAudioCheckResult { ok, unreachable, notAudio }

Future<UrlAudioCheckResult> checkAudioUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return UrlAudioCheckResult.unreachable;

  try {
    // HEAD first — cheap, doesn't download the body
    final response = await http
        .head(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return UrlAudioCheckResult.unreachable;
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.startsWith('audio/') ||
        contentType == 'application/octet-stream') {
      return UrlAudioCheckResult.ok;
    }
    return UrlAudioCheckResult.notAudio;
  } catch (_) {
    return UrlAudioCheckResult.unreachable;
  }
}