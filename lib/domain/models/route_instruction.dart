class RouteInstruction {
  final String instruction;
  final double? distanceKm;
  final double? timeSeconds;

  const RouteInstruction({
    required this.instruction,
    this.distanceKm,
    this.timeSeconds,
  });
}
