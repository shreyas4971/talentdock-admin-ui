import 'dart:html' as html;
import 'dart:typed_data';

void downloadFileWeb(Uint8List bytes, String fileName, {String mimeType = 'application/pdf'}) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  
  // Revoke the object URL after a short delay
  Future.delayed(const Duration(seconds: 1), () {
    html.Url.revokeObjectUrl(url);
  });
}

void previewFileWeb(Uint8List bytes, {String mimeType = 'application/pdf'}) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');

  // Keep URL valid for a reasonable duration before revoking
  Future.delayed(const Duration(minutes: 5), () {
    html.Url.revokeObjectUrl(url);
  });
}
