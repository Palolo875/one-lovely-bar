import '../models/weather_condition.dart';
import '../repositories/weather_repository.dart';

class GetForecast {
  final WeatherRepository _repository;

  const GetForecast(this._repository);

  Future<List<WeatherCondition>> call(double lat, double lng, {int days = 7}) {
    return _repository.getForecast(lat, lng, days: days);
  }
}
