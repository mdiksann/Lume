import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://books.google.com/books/content?id=8eFvEAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api');
  final response = await http.get(url);
  print('Status: ${response.statusCode}');
  print('Content-Type: ${response.headers['content-type']}');
  print('Length: ${response.bodyBytes.length}');
  if (response.bodyBytes.length > 50) {
    print('First 50 chars: ${String.fromCharCodes(response.bodyBytes.take(50))}');
  }
}
