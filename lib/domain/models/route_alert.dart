enum RouteAlertType {
  precipitation,
  wind,
  temperatureLow,
  temperatureHigh,
}

class RouteAlert {
  final RouteAlertType type;
  final String title;
  final String message;

  const RouteAlert({
    required this.type,
    required this.title,
    required this.message,
  });
}
