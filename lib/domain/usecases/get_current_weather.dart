import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';

class GetCurrentWeather {

  const GetCurrentWeather(this._repository);
  final WeatherRepository _repository;

  Future<WeatherCondition> call(double lat, double lng) {
    return _repository.getCurrentWeather(lat, lng);
  }
}
