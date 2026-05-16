import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final uri = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=Animal+Farm');
  final response = await http.get(uri);
  print(response.body);
}
