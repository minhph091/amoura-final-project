import 'dart:io';
import 'dart:math';

class FileUtils {
  static Future<String> getFileSizeString({required File file}) async {
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";

    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}
