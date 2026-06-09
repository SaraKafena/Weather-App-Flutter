import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = 'ab1da6872efa9bf4567572ac5d4bc9b3';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> getWeather(String cityName) async {
    // BuilURL
    final url = Uri.parse(
      '$baseUrl?q=$cityName&appid=$apiKey&units=metric'
    );

    //send request
    final response = await http.get(url);

    if (response.statusCode == 200) {
  return WeatherModel.fromJson(jsonDecode(response.body));
} else {
  throw Exception('Error ${response.statusCode}: ${response.body}');
}
  }
}