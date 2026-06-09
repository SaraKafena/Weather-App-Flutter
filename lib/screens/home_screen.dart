import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchWeather() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final weather = await _weatherService.getWeather(_controller.text.trim());
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<Color> _getGradientColors() {
    if (_weather == null) return [const Color(0xFF89CFF0), const Color(0xFFB6D8F2), const Color(0xFFD4B8E0)];
    final desc = _weather!.description.toLowerCase();
    if (desc.contains('rain') || desc.contains('drizzle')) {
      return [const Color(0xFF4A6FA5), const Color(0xFF6B8FC4), const Color(0xFF9BB5D9)];
    } else if (desc.contains('cloud')) {
      return [const Color(0xFF8AAEC4), const Color(0xFFAAC4D8), const Color(0xFFCCDDEB)];
    } else if (desc.contains('snow')) {
      return [const Color(0xFFB8D4E8), const Color(0xFFD0E8F5), const Color(0xFFEEF6FF)];
    } else if (desc.contains('thunder')) {
      return [const Color(0xFF3D4A6B), const Color(0xFF5A6B8A), const Color(0xFF7A8FAA)];
    } else {
      // Clear / Sunny
      return [const Color(0xFF5BB8F5), const Color(0xFF89CFF0), const Color(0xFFFFD89B)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header
                const Text(
                  '🌤 Weather',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  'Check any city worldwide',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 32),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 32),

                // Content
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (_errorMessage != null)
                  _buildError()
                else if (_weather != null)
                  _buildWeatherContent()
                else
                  _buildPlaceholder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _fetchWeather(),
                ),
              ),
              GestureDetector(
                onTap: _fetchWeather,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Go',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      children: [
        // Main Card
        _buildGlassCard(
          child: Column(
            children: [
              // Icon + Temp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_weather!.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w200,
                          height: 1,
                        ),
                      ),
                      Text(
                        _weather!.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weather!.description.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  Image.network(
                    'https://openweathermap.org/img/wn/${_weather!.icon}@2x.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Details Row
        Row(
          children: [
            Expanded(child: _buildSmallCard(Icons.thermostat_outlined, 'Feels Like', '${_weather!.feelsLike.round()}°C')),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallCard(Icons.water_drop_outlined, 'Humidity', '${_weather!.humidity}%')),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallCard(Icons.air, 'Wind', '${_weather!.windSpeed}m/s')),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSmallCard(IconData icon, String label, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return _buildGlassCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: const [
            Text('🌍', style: TextStyle(fontSize: 80)),
            SizedBox(height: 20),
            Text(
              'Search for a city\nto see the weather',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}