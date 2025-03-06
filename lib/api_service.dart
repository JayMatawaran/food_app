import 'dart:convert';
import 'package:http/http.dart' as http;

import 'constants.dart';

class ApiService {
  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse(ApiEndpoints.categoriesUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['productCategories'];
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<Map<String, dynamic>> fetchLogoAndImages() async {
    final response = await http.get(
      Uri.parse('https://raw.githubusercontent.com/JayMatawaran/APIs/refs/heads/main/logo.json'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load logo and images');
    }
  }

  static Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://raw.githubusercontent.com/JayMatawaran/APIs/refs/heads/main/products.json'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['products'];
    } else {
      throw Exception('Failed to load products');
    }
  }
}