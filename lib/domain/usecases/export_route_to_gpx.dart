import '../models/route_models.dart';

class ExportRouteToGpx {
  const ExportRouteToGpx();

  String call(RouteData route) {
    final sb = StringBuffer();

    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln('<gpx version="1.1" creator="WeatherNav" xmlns="http://www.topografix.com/GPX/1/1">');
    sb.writeln('<trk>');
    sb.writeln('<name>WeatherNav Route</name>');
    sb.writeln('<trkseg>');

    for (final p in route.points) {
      sb.write('<trkpt lat="${p.latitude}" lon="${p.longitude}">');
      if (p.timestamp != null) {
        sb.write('<time>${p.timestamp!.toUtc().toIso8601String()}</time>');
      }
      sb.writeln('</trkpt>');
    }

    sb.writeln('</trkseg>');
    sb.writeln('</trk>');
    sb.writeln('</gpx>');

    return sb.toString();
  }
}
