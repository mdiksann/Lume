import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://corsproxy.io/?https%3A%2F%2Fbooks.google.com%2Fbooks%2Fcontent%3Fid%3D8eFvEAAAQBAJ%26printsec%3Dfrontcover%26img%3D1%26zoom%3D1%26source%3Dgbs_api');
  final response = await http.get(url);
  print('Headers: ${response.headers}');
}
