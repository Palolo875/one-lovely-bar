class RouteInstruction {

  const RouteInstruction({
    required this.instruction,
    this.distanceKm,
    this.timeSeconds,
  });
  final String instruction;
  final double? distanceKm;
  final double? timeSeconds;
}
