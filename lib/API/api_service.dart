import 'dart:convert';
import 'package:tugas4/models/meal_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const _apiKey = '7471976f73c64077b8cb6fcc567680b6';
  final String _baseUrl =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

  Future<List<Meal>> fetchMeals() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> mealsJson = json['meals'];

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Gagal Memuat Menu');
      }
    } catch (e) {
      throw Exception('Gagal Menghubungkan: $e');
    }
  }
}