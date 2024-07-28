class CancellationTokenException implements Exception {
  CancellationTokenException(this.message);
  final String message;
  @override
  String toString() => 'Request Cancelled: $message';
}
