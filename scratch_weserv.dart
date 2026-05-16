import 'package:http/http.dart' as http;

void main() async {
  final target = 'https://books.google.com/books/content?id=8eFvEAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api';
  final url = Uri.parse('https://images.weserv.nl/?url=${Uri.encodeComponent(target)}');
  final response = await http.get(url);
  print('Status: ${response.statusCode}');
  print('Headers: ${response.headers}');
}
