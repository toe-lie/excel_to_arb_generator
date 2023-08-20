import 'dart:io';

class ExcelDownloader {
  const ExcelDownloader({required this.url});

  final String url;

  Future<void> downloadAndCreateExcelFile(File file) async {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    await response.pipe(file.openWrite());
  }

  Future<void> deleteExcelFile(File file) async {
    await file.delete();
  }
}