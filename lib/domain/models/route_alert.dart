enum RouteAlertType {
  precipitation,
  wind,
  temperatureLow,
  temperatureHigh,
}

class RouteAlert {

  const RouteAlert({
    required this.type,
    required this.title,
    required this.message,
  });
  final RouteAlertType type;
  final String title;
  final String message;
}
