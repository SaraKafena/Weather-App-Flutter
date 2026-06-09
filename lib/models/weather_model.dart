class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String description;
  final String icon;
  final double windSpeed;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName:    json['name'],
      temperature: json['main']['temp'].toDouble(),
      feelsLike:   json['main']['feels_like'].toDouble(),
      humidity:    json['main']['humidity'],
      description: json['weather'][0]['description'],
      icon:        json['weather'][0]['icon'],
      windSpeed:   json['wind']['speed'].toDouble(),
    );
  }
}