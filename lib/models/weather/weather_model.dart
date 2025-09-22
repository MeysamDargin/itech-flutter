class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });
}

class Weather {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final List<HourlyWeather> hourly;

  Weather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.hourly,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final hourlyData = json['hourly'];
    final List<HourlyWeather> hourly = [];
    if (hourlyData != null) {
      final times = hourlyData['time'] as List;
      final temperatures = hourlyData['temperature_2m'] as List;
      final weatherCodes = hourlyData['weathercode'] as List;

      for (int i = 0; i < times.length; i++) {
        hourly.add(
          HourlyWeather(
            time: DateTime.parse(times[i]),
            temperature: (temperatures[i] as num).toDouble(),
            weatherCode: weatherCodes[i] as int,
          ),
        );
      }
    }

    return Weather(
      temperature: json['current_weather']['temperature'] as double,
      windSpeed: json['current_weather']['windspeed'] as double,
      weatherCode: json['current_weather']['weathercode'] as int,
      hourly: hourly,
    );
  }
}
