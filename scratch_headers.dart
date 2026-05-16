import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://books.google.com/books/content?id=8eFvEAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api');
  final response = await http.get(url);
  print('Headers: ${response.headers}');
}
