import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';

class GetForecast {

  const GetForecast(this._repository);
  final WeatherRepository _repository;

  Future<List<WeatherCondition>> call(double lat, double lng, {int days = 7}) {
    return _repository.getForecast(lat, lng, days: days);
  }
}
