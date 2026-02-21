import '../models/weather_condition.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeather {
  final WeatherRepository _repository;

  const GetCurrentWeather(this._repository);

  Future<WeatherCondition> call(double lat, double lng) {
    return _repository.getCurrentWeather(lat, lng);
  }
}
