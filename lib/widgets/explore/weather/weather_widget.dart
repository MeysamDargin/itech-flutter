import 'package:flutter/material.dart';
import 'package:itech/models/weather/weather_model.dart';
import 'package:itech/service/weather/location_service.dart';
import 'package:itech/service/weather/weather_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String _locationName = "Loading...";
  Timer? _timer;
  Weather? _lastWeatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (Timer t) => _fetchWeather(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      final position = await LocationService().getCurrentLocation();
      final placemark = await LocationService().getPlacemark(
        position.latitude,
        position.longitude,
      );
      final weatherData = await WeatherService().getWeather(
        position.latitude,
        position.longitude,
      );

      // فقط در صورت موفقیت، داده‌ها را به‌روزرسانی کن
      if (mounted) {
        setState(() {
          _lastWeatherData = weatherData;
          _locationName = placemark;
        });
      }
    } catch (e) {
      // در صورت خطا، هیچ کاری نکن و داده قبلی باقی بماند
      print('Error fetching weather: $e');
    }
  }

  String _getWeatherDescription(int code, double temperature) {
    String condition;
    String suggestion;

    switch (code) {
      case 0:
        condition = "Sunny";
        suggestion = "Perfect time for walking and outdoor exercise";
        break;
      case 1:
      case 2:
      case 3:
        condition = "Cloudy";
        suggestion = "Good weather for outdoor activities";
        break;
      case 45:
      case 48:
        condition = "Foggy";
        suggestion = "Drive carefully and reduce your speed";
        break;
      case 51:
      case 53:
      case 55:
        condition = "Drizzle";
        suggestion = "Carry an umbrella with you";
        break;
      case 61:
      case 63:
      case 65:
        condition = "Rainy";
        suggestion = "Wear warm clothes and use an umbrella";
        break;
      case 66:
      case 67:
        condition = "Freezing rain";
        suggestion = "Avoid unnecessary outdoor activities";
        break;
      case 71:
      case 73:
      case 75:
        condition = "Snowy";
        suggestion = "Wear warm clothes and be cautious";
        break;
      case 77:
        condition = "Hail";
        suggestion = "Stay in a safe place";
        break;
      case 80:
      case 81:
      case 82:
        condition = "Rain showers";
        suggestion = "Avoid outdoor activities";
        break;
      case 85:
      case 86:
        condition = "Heavy snow";
        suggestion = "Stay home and keep yourself warm";
        break;
      case 95:
        condition = "Thunderstorm";
        suggestion = "Do not go outside safe places";
        break;
      case 96:
      case 99:
        condition = "Storm";
        suggestion = "Stay in a safe place and avoid going out";
        break;
      default:
        condition = "Sunny";
        suggestion = "A beautiful day for outdoor activities";
    }

    return "$condition, the current temperature is ${temperature.round()}°C, $suggestion";
  }

  List<HourlyWeather> _getNext24HoursWeather(
    List<HourlyWeather> hourlyWeather,
  ) {
    final now = DateTime.now();
    final next24Hours = now.add(const Duration(hours: 24));

    return hourlyWeather.where((weather) {
      return weather.time.isAfter(now) && weather.time.isBefore(next24Hours);
    }).toList();
  }

  // ویجت شیمر برای متن توضیح آب و هوا
  Widget _buildDescriptionShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 17,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 17,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ویجت شیمر برای کارت اصلی آب و هوا
  Widget _buildWeatherCardShimmer() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color(0xff1B9CFA),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.7),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // شیمر برای آیکون آب و هوا
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // شیمر برای دما
                        Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // شیمر برای نام مکان
                        Container(
                          width: 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // شیمر برای سرعت باد
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 70,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 50,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // شیمر برای پیش‌بینی ساعتی
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8, // تعداد ثابت برای نمایش شیمر
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        // شیمر برای ساعت
                        Container(
                          width: 40,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // شیمر برای آیکون
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // شیمر برای دما
                        Container(
                          width: 30,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        // متن توضیح آب و هوا
        if (_lastWeatherData != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Text(
              _getWeatherDescription(
                _lastWeatherData!.weatherCode,
                _lastWeatherData!.temperature,
              ),
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'a-r',
                color: textTheme.bodyMedium!.color,
              ),
              textAlign: TextAlign.start,
            ),
          )
        else
          _buildDescriptionShimmer(),

        // ویجت اصلی آب و هوا
        if (_lastWeatherData == null)
          _buildWeatherCardShimmer()
        else
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Color(0xff1B9CFA),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image(
                          image: AssetImage(
                            _getWeatherImagePath(_lastWeatherData!.weatherCode),
                          ),
                          width: 50,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_lastWeatherData!.temperature}°C',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _locationName,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Wind Speed \n ${_lastWeatherData!.windSpeed} km/h',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        _getNext24HoursWeather(_lastWeatherData!.hourly).length,
                    itemBuilder: (context, index) {
                      final next24Hours = _getNext24HoursWeather(
                        _lastWeatherData!.hourly,
                      );
                      final hourlyWeather = next24Hours[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Text(
                              DateFormat.j().format(hourlyWeather.time),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              _getWeatherIcon(hourlyWeather.weatherCode),
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${hourlyWeather.temperature.round()}°',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
        return Icons.grain;
      case 61:
      case 63:
      case 65:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.ac_unit;
      case 95:
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }

  String _getWeatherImagePath(int code) {
    switch (code) {
      case 0:
        // Clear sky
        return 'assets/weather_icons/icons8-summer-100.png';
      case 1:
      case 2:
      case 3:
        // Mainly clear, partly cloudy, and overcast
        return 'assets/weather_icons/icons8-partly-cloudy-day-100.png';
      case 45:
      case 48:
        // Fog and depositing rime fog
        return 'assets/weather_icons/icons8-windy-weather-100.png';
      case 51:
      case 53:
      case 55:
        // Drizzle: Light, moderate, and dense intensity
        return 'assets/weather_icons/icons8-light-rain-100.png';
      case 61:
      case 63:
      case 65:
        // Rain: Slight, moderate and heavy intensity
        return 'assets/weather_icons/icons8-rain-100.png';
      case 66:
      case 67:
        // Freezing Rain: Light and heavy intensity
        return 'assets/weather_icons/icons8-heavy-rain-100.png';
      case 71:
      case 73:
      case 75:
        // Snow fall: Slight, moderate, and heavy intensity
        return 'assets/weather_icons/icons8-winter-100.png';
      case 77:
        // Snow grains
        return 'assets/weather_icons/icons8-snow-100 (1).png';
      case 80:
      case 81:
      case 82:
        // Rain showers: Slight, moderate, and violent
        return 'assets/weather_icons/icons8-heavy-rain-100.png';
      case 85:
      case 86:
        // Snow showers slight and heavy
        return 'assets/weather_icons/icons8-heavy-rain-100.png';
      case 95:
        // Thunderstorm: Slight or moderate
        return 'assets/weather_icons/icons8-cloud-lightning-100.png';
      case 96:
      case 99:
        // Thunderstorm with slight and heavy hail
        return 'assets/weather_icons/icons8-storm-with-heavy-rain-100.png';
      default:
        return 'assets/weather_icons/icons8-summer-100.png';
    }
  }
}
