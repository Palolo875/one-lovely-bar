abstract class TtsService {
  Future<void> speakLines(List<String> lines);
  Future<void> stop();
  Future<void> dispose();
}
